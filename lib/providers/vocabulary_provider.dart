import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/mock_data.dart';

class VocabularyProvider extends ChangeNotifier {
  final List<TennisVocabulary> _allVocab = [];
  final Set<String> _favoriteIds = {};
  VocabCategory? _selectedCategory;

  VocabularyProvider() {
    _allVocab.addAll(MockData.generateVocabulary());
  }

  List<TennisVocabulary> get allVocab => _allVocab;
  Set<String> get favoriteIds => _favoriteIds;
  VocabCategory? get selectedCategory => _selectedCategory;

  List<TennisVocabulary> get filteredVocab {
    if (_selectedCategory == null) return _allVocab;
    return _allVocab.where((v) => v.category == _selectedCategory).toList();
  }

  List<TennisVocabulary> get favorites =>
      _allVocab.where((v) => _favoriteIds.contains(v.id)).toList();

  void loadMockData() {
    _allVocab.clear();
    _allVocab.addAll(MockData.generateVocabulary());
    notifyListeners();
  }

  void selectCategory(VocabCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      final vocab = _allVocab.firstWhere((v) => v.id == id);
      vocab.isFavorited = false;
    } else {
      _favoriteIds.add(id);
      final vocab = _allVocab.firstWhere((v) => v.id == id);
      vocab.isFavorited = true;
    }
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);
}
