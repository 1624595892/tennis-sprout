import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Generates tennis ball PNG icons at multiple resolutions.
/// Run with: dart run tool/generate_icons.dart
void main() {
  for (final size in [192, 512]) {
    final bytes = _generateTennisBallPng(size);
    File('web/icons/Icon-$size.png').writeAsBytesSync(bytes);
    print('Generated Icon-$size.png (${bytes.length} bytes)');
  }
  // Also generate favicon.png (32x32)
  final favicon = _generateTennisBallPng(32);
  File('web/favicon.png').writeAsBytesSync(favicon);
  print('Generated favicon.png (${favicon.length} bytes)');
  print('Done!');
}

Uint8List _generateTennisBallPng(int size) {
  final pixels = Uint8List(size * size * 4); // RGBA

  final cx = size / 2;
  final cy = size / 2;
  final r = size * 0.44;

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final i = (y * size + x) * 4;
      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist > r + 1.5) {
        // Transparent background
        pixels[i] = 0;
        pixels[i + 1] = 0;
        pixels[i + 2] = 0;
        pixels[i + 3] = 0;
        continue;
      }

      // Ball gradient: B8D062 (yellowGreen) to A3BD46 (darker)
      final t = (dist / r).clamp(0.0, 1.0);
      final rr = 0xB8 + (0xA3 - 0xB8) * t * 1.2;
      final gg = 0xD0 + (0xBD - 0xD0) * t * 1.2;
      final bb = 0x62 + (0x46 - 0x62) * t * 1.2;

      // Highlight from top-left
      final hl = math.max(0.0, 1.0 - dist / (r * 0.5) - (dx + dy) / (r * 4));
      final bright = math.min(1.0, 1.0 + hl * 0.4);

      pixels[i] = (rr * bright).round().clamp(0, 255);
      pixels[i + 1] = (gg * bright).round().clamp(0, 255);
      pixels[i + 2] = (bb * bright).round().clamp(0, 255);
      pixels[i + 3] = 255; // opaque

      // Anti-aliased edge
      if (dist > r - 0.8) {
        final alpha = ((r + 1.5 - dist) / 2.3).clamp(0.0, 1.0);
        pixels[i + 3] = (alpha * 255).round();
      }
    }
  }

  // Draw white seam lines
  _drawLine(pixels, size, size / 2, size * 0.15, size / 2, size * 0.85, 1.6);
  _drawArc(pixels, size, cx, cy, r * 0.7, 0.0, math.pi, 1.5);
  _drawArc(pixels, size, cx, cy, r * 0.7, math.pi, 2 * math.pi, 1.5);

  return _encodePng(pixels, size, size);
}

void _drawLine(Uint8List pixels, int size, double x1, double y1, double x2, double y2, double thickness) {
  final steps = math.max((x2 - x1).abs(), (y2 - y1).abs()).ceil();
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final x = (x1 + (x2 - x1) * t).round();
    final y = (y1 + (y2 - y1) * t).round();
    _paintDot(pixels, size, x, y, thickness, 255, 255, 255);
  }
}

void _drawArc(Uint8List pixels, int size, double cx, double cy, double rx, double startAngle, double endAngle, double thickness) {
  final steps = 120;
  for (var i = 0; i <= steps; i++) {
    final angle = startAngle + (endAngle - startAngle) * i / steps;
    final x = (cx + rx * math.cos(angle)).round();
    final y = (cy + rx * math.sin(angle) * 0.3).round();
    _paintDot(pixels, size, x, y, thickness, 255, 255, 255);
  }
}

void _paintDot(Uint8List pixels, int size, int x, int y, double r, int pr, int pg, int pb) {
  for (var dy = (-r).ceil(); dy <= r; dy++) {
    for (var dx = (-r).ceil(); dx <= r; dx++) {
      final px = x + dx;
      final py = y + dy;
      if (px < 0 || px >= size || py < 0 || py >= size) continue;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist > r) continue;
      final i = (py * size + px) * 4;
      final alpha = (math.max(0.0, r - dist) / r).clamp(0.0, 1.0);
      pixels[i] = (pr * alpha + pixels[i] * (1 - alpha)).round();
      pixels[i + 1] = (pg * alpha + pixels[i + 1] * (1 - alpha)).round();
      pixels[i + 2] = (pb * alpha + pixels[i + 2] * (1 - alpha)).round();
      pixels[i + 3] = math.max(pixels[i + 3], (alpha * 255).round());
    }
  }
}

/// Minimal PNG encoder using zlib for IDAT.
Uint8List _encodePng(Uint8List rgba, int width, int height) {
  // Build raw filtered scanlines (filter byte 0 = None, then RGBA)
  final raw = Uint8List(height * (1 + width * 4));
  for (var y = 0; y < height; y++) {
    final src = y * width * 4;
    final dst = y * (1 + width * 4);
    raw[dst] = 0; // filter: None
    for (var x = 0; x < width * 4; x++) {
      raw[dst + 1 + x] = rgba[src + x];
    }
  }

  // Compress with zlib
  final compressed = Uint8List.fromList(ZLibCodec().encode(raw));

  // Build PNG binary
  final signature = [137, 80, 78, 71, 13, 10, 26, 10]; // PNG header

  // IHDR
  final ihdrData = BytesBuilder();
  ihdrData.add(_u32(width));
  ihdrData.add(_u32(height));
  ihdrData.add([8, 6, 0, 0, 0]); // 8-bit RGBA, no interlace
  final ihdr = _chunk('IHDR', ihdrData.toBytes());

  // IDAT
  final idat = _chunk('IDAT', compressed);

  // IEND
  final iend = _chunk('IEND', Uint8List(0));

  // Combine
  final result = BytesBuilder();
  result.add(Uint8List.fromList(signature));
  result.add(ihdr);
  result.add(idat);
  result.add(iend);

  return result.toBytes();
}

Uint8List _chunk(String type, Uint8List data) {
  final len = _u32(data.length);
  final typeBytes = Uint8List.fromList(type.codeUnits);
  final crcData = Uint8List(typeBytes.length + data.length);
  crcData.setAll(0, typeBytes);
  crcData.setAll(typeBytes.length, data);
  final crc = _crc32(crcData);

  final result = BytesBuilder();
  result.add(len);
  result.add(typeBytes);
  result.add(data);
  result.add(_u32(crc));
  return result.toBytes();
}

Uint8List _u32(int n) {
  return Uint8List(4)
    ..buffer.asByteData().setUint32(0, n, Endian.big);
}

int _crc32(Uint8List data) {
  int crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}

extension on double {
  double clamp(double min, double max) => math.max(min, math.min(max, this));
}
