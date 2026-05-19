import 'package:flutter/material.dart';
import '../models/skill_tree.dart';
import '../services/mock_data.dart';

class SkillTreeProvider extends ChangeNotifier {
  late SkillTree _skillTree;

  SkillTreeProvider() {
    _skillTree = MockData.generateSkillTree();
  }

  SkillTree get skillTree => _skillTree;
  List<SkillBranch> get branches => _skillTree.branches;
  double get ntprEstimate => _skillTree.estimateNtrp();

  void setLeafLevel(String branchId, String leafId, double level) {
    final branch = _skillTree.branches.firstWhere((b) => b.id == branchId);
    final leaf = branch.leaves.firstWhere((l) => l.id == leafId);
    leaf.level = level;
    notifyListeners();
  }

  double getBranchAverage(String branchId) {
    final branch = _skillTree.branches.firstWhere((b) => b.id == branchId);
    return branch.average;
  }
}
