import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/chaupar.dart';
import 'src/config.dart';
import 'src/widgets/overlay_screen.dart';

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chaupar Chakravyuh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Chaupar game;

  @override
  void initState() {
    super.initState();
    game = Chaupar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  child: SizedBox(
                    height: gameHeight,
                    width: gameWidth,
                    child: GameWidget(
                      game: game,
                      overlayBuilderMap: {
                        GameState.initial.name: (context, game) =>
                            const OverlayScreen(
                                title: 'TAP TO PLAY',
                                subtitle: 'Use arrow keys or swipe'),
                        GameState.over.name: (context, game) =>
                            const OverlayScreen(
                              title: 'G A M E   O V E R',
                              subtitle: 'Tap to Play Again',
                            ),
                        GameState.won.name: (context, game) =>
                            const OverlayScreen(
                              title: 'YOU WON !!!',
                              subtitle: 'Tap to Play Again',
                            ),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
