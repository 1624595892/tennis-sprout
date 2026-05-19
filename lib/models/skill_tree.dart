class SkillTree {
  final List<SkillBranch> branches;

  SkillTree({required this.branches});

  double get overallAverage {
    if (branches.isEmpty) return 1.0;
    double sum = 0;
    int count = 0;
    for (final branch in branches) {
      for (final leaf in branch.leaves) {
        sum += leaf.level;
        count++;
      }
    }
    return count > 0 ? sum / count : 1.0;
  }

  double estimateNtrp() {
    final avg = overallAverage;
    // Map 1-10 skill level → NTRP 1.0-7.0
    return 1.0 + (avg - 1.0) * (6.0 / 9.0);
  }
}

class SkillBranch {
  final String id;
  final String nameKey; // i18n key prefix
  final List<SkillLeaf> leaves;

  SkillBranch({required this.id, required this.nameKey, required this.leaves});

  double get average =>
      leaves.isEmpty ? 1.0 : leaves.map((l) => l.level).reduce((a, b) => a + b) / leaves.length;
}

class SkillLeaf {
  final String id;
  final String nameKey;
  double level; // 1-10

  SkillLeaf({required this.id, required this.nameKey, this.level = 1.0});
}
