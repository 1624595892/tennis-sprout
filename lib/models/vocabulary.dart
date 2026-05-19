class TennisVocabulary {
  final String id;
  final String wordEn;
  final String wordZh;
  final String illustrationAsset;
  final String pronunciationUrl;
  final String principleEn;
  final String principleZh;
  final String triviaEn;
  final String triviaZh;
  final VocabCategory category;
  bool isFavorited;

  TennisVocabulary({
    required this.id,
    required this.wordEn,
    required this.wordZh,
    required this.illustrationAsset,
    required this.pronunciationUrl,
    required this.principleEn,
    required this.principleZh,
    required this.triviaEn,
    required this.triviaZh,
    required this.category,
    this.isFavorited = false,
  });

  String principle(bool isZh) => isZh ? principleZh : principleEn;
  String trivia(bool isZh) => isZh ? triviaZh : triviaEn;
}

enum VocabCategory {
  technique,
  tactics,
  rules,
  equipment,
  culture;

  String get key => switch (this) {
    technique => 'technique',
    tactics => 'tactics',
    rules => 'rules',
    equipment => 'equipment',
    culture => 'culture',
  };
}
