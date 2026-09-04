import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_data.dart';

class GameState extends ChangeNotifier {
  List<LevelData> levels = [];
  Color currentColor = Colors.red;

  GameState() {
    _initLevels();
  }

  Future<void> _initLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLevels = prefs.getString('levels');

    if (savedLevels != null) {
      final List<dynamic> decoded = jsonDecode(savedLevels);
      levels = decoded.map((e) => LevelData.fromJson(e)).toList();
    } else {
      // Initialize 50 levels (mock data)
      final categories = ['animals', 'flowers', 'items', 'people'];
      for (int i = 0; i < 50; i++) {
        String cat = categories[i % categories.length];
        levels.add(LevelData(
          id: i,
          category: cat,
          imagePath: 'assets/images/$cat/image_$i.svg', // These files will need to be provided
          isUnlocked: i == 0, // Only first level is unlocked initially
        ));
      }
      _saveLevels();
    }
    notifyListeners();
  }

  Future<void> _saveLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(levels.map((e) => e.toJson()).toList());
    await prefs.setString('levels', encoded);
  }

  void completeLevel(int id) {
    final level = levels.firstWhere((l) => l.id == id);
    level.isCompleted = true;
    
    // Unlock next level
    if (id + 1 < levels.length) {
      levels.firstWhere((l) => l.id == id + 1).isUnlocked = true;
    }
    _saveLevels();
    notifyListeners();
  }

  void setCurrentColor(Color color) {
    currentColor = color;
    notifyListeners();
  }
}
