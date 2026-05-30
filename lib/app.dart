import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'i18n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'screens/main_shell.dart';
import 'screens/vocab_academy_screen.dart';
import 'screens/login_screen.dart';
import 'screens/practice_log_screen.dart';
import 'screens/growth_trajectory_screen.dart';

class TennisSproutApp extends StatelessWidget {
  const TennisSproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'TennisSprout',
      debugShowCheckedModeBanner: false,
      theme: TennisTheme.lightTheme,
      builder: (context, child) => _buildDesktopSimulator(context, child),
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('zh');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return const Locale('zh');
      },
      initialRoute: AppRoutes.home,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _buildRoute(const MainShell(), settings);

      case AppRoutes.vocabAcademy:
        return _buildRoute(const VocabAcademyScreen(), settings);

      case AppRoutes.skillTree:
        return _buildRoute(const _PlaceholderScreen(title: 'Skill Tree'), settings);

      case AppRoutes.practiceLog:
        return _buildRoute(PracticeLogScreen(initialDate: settings.arguments as DateTime?), settings);

      case AppRoutes.growthTrajectory:
        return _buildRoute(const GrowthTrajectoryScreen(), settings);

      case AppRoutes.matchRecorder:
        return _buildRoute(const _PlaceholderScreen(title: 'Match Recorder'), settings);

      case AppRoutes.insights:
        return _buildRoute(const _PlaceholderScreen(title: 'Insights'), settings);

      case AppRoutes.profile:
        return _buildRoute(const _PlaceholderScreen(title: 'Profile'), settings);

      case AppRoutes.coachBinding:
        return _buildRoute(const _PlaceholderScreen(title: 'Coach Binding'), settings);

      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);

      default:
        return _buildRoute(const MainShell(), settings);
    }
  }

  PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

Widget _buildDesktopSimulator(BuildContext context, Widget? child) {
  // Only wrap on desktop (macOS / Windows), not on web or mobile
  if (kIsWeb ||
      !(defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    return child ?? const SizedBox.shrink();
  }

  return Scaffold(
    backgroundColor: const Color(0xFFEFEFEF),
    body: Center(
      child: Container(
        width: 393,
        height: 852,
        decoration: BoxDecoration(
          color: AppColors.wisteria,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 47, bottom: 34),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: child,
          ),
        ),
      ),
    ),
  );
}

// Temporary placeholder for unimplemented screens
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TennisColors.lavenderLight,
      appBar: AppBar(
        backgroundColor: TennisColors.deepPurple,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: TennisColors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in next phase...',
              style: TextStyle(
                fontSize: 14,
                color: TennisColors.deepPurple.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
