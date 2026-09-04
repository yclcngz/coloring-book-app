import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/game_state.dart';
import '../models/level_data.dart';
import '../utils/ad_helper.dart';
import '../utils/svg_colorer.dart';

class ColoringScreen extends StatefulWidget {
  final LevelData level;

  const ColoringScreen({Key? key, required this.level}) : super(key: key);

  @override
  _ColoringScreenState createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  List<ColorablePath> _paths = [];
  bool _isLoading = true;
  
  // Example dummy SVG for testing if asset is missing
  final String dummySvgPathData = "M 10 10 H 90 V 90 H 10 L 10 10";

  final List<Color> _palette = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey, Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadInterstitialAd();
    }
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    final paths = await SvgParser.parseSvg(widget.level.imagePath);
    if (paths.isEmpty) {
      // Create a dummy rectangle path if SVG is missing/not found
      // (Assuming parseSvgPathData is already imported via svg_colorer.dart or top-level import)
      _paths = [ColorablePath(path: parseSvgPathData(dummySvgPathData))];
    } else {
      _paths = paths;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Navigator.pop(context); // Go back after ad
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              Navigator.pop(context); // Go back if ad fails
            },
          );
        },
        onAdFailedToLoad: (err) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _handleTap(Offset position, Size size, Size originalSize) {
    // Convert tap position to original SVG coordinates
    final scaleX = size.width / originalSize.width;
    final scaleY = size.height / originalSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final dx = (size.width - originalSize.width * scale) / 2;
    final dy = (size.height - originalSize.height * scale) / 2;

    final tapX = (position.dx - dx) / scale;
    final tapY = (position.dy - dy) / scale;

    final tapOffset = Offset(tapX, tapY);

    final gameState = context.read<GameState>();

    // Find which path was tapped (checking backwards to hit top layers first if overlapping)
    for (int i = _paths.length - 1; i >= 0; i--) {
      if (_paths[i].path.contains(tapOffset)) {
        setState(() {
          _paths[i].color = gameState.currentColor;
        });
        break; // Only color the top-most touched path
      }
    }
  }

  void _finishLevel() {
    context.read<GameState>().completeLevel(widget.level.id);
    
    if (!kIsWeb && _isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final gameState = context.watch<GameState>();
    final originalSvgSize = const Size(500, 500); // Assume a standard size, can be parsed from SVG viewBox

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations?.level?.replaceFirst('{levelNumber}', (widget.level.id + 1).toString()) ?? 'Level ${widget.level.id + 1}'}'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                for (var p in _paths) p.color = Colors.white;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _finishLevel,
          )
        ],
      ),
      body: Row(
        children: [
          // Color Palette
          Container(
            width: 80,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: _palette.length,
              itemBuilder: (context, index) {
                final color = _palette[index];
                final isSelected = gameState.currentColor == color;
                return GestureDetector(
                  onTap: () => gameState.setCurrentColor(color),
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Drawing Canvas
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onTapUp: (details) {
                        _handleTap(details.localPosition, size, originalSvgSize);
                      },
                      child: CustomPaint(
                        size: size,
                        painter: ColoringPainter(
                          paths: _paths,
                          originalSize: originalSvgSize,
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
