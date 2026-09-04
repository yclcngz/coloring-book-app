import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/game_state.dart';
import '../models/level_data.dart';
import 'coloring_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.categories ?? 'Categories'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: gameState.levels.length,
          itemBuilder: (context, index) {
            final level = gameState.levels[index];
            return LevelCard(level: level);
          },
        ),
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final LevelData level;

  const LevelCard({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: level.isUnlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ColoringScreen(level: level),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: level.isUnlocked ? Colors.lightGreen : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (level.isUnlocked)
              Text(
                '${level.id + 1}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              )
            else
              const Icon(Icons.lock, size: 40, color: Colors.grey),
            if (level.isCompleted)
              const Positioned(
                bottom: 8,
                right: 8,
                child: Icon(Icons.star, color: Colors.amber, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}
