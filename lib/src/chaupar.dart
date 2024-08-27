import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'config.dart';

typedef Coord = (int, int);

enum GameState { initial, playing, paused, over, won }

final playablePieces = {PieceType.yellow, PieceType.red, PieceType.black, PieceType.green};

/// Chaupar is Ancient Indian Game.
class Chaupar extends FlameGame
    with
        HasPerformanceTracker,
        TapDetector,
        DragCallbacks,
        HasCollisionDetection {
  Chaupar()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  double get width => size.x;
  double get height => size.y;

  late GameState _gameState;
  GameState get gameState => _gameState;
  set gameState(GameState value) {
    _gameState = value;
    switch (value) {
      case GameState.initial:
      case GameState.over:
      case GameState.won:
        overlays.add(value.name);
      case GameState.playing:
      case GameState.paused:
        overlays.remove(GameState.initial.name);
        overlays.remove(GameState.over.name);
        overlays.remove(GameState.won.name);
    }
  }

  late Vector2 boardPosition;
  late Map<Coord, Offset> boardOffsetMap = {};
  late Map<PieceType, List<Coord>> pathCoordinates = {};
  late Map<PieceType, List<Piece>> pieces = {};
  late int currentPlayer;

  late List<Piece> collisionPieces = [];

  @override
  bool debugMode = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());
    gameState = GameState.initial;

    // Calculate the total path length
    final totalPathLength = yellowHandCoords.length;
    // Calculate the path length for each piece row path
    final pathLength = totalPathLength ~/ 3;
    // Create a map to store the path coordinates for each piece type
    pathCoordinates = {
      PieceType.yellow: [
        ...yellowHandCoords.getRange(0, pathLength * 2),
        ...redHandCoords.getRange(pathLength * 2, totalPathLength),
        ...redHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...blackHandCoords.getRange(pathLength * 2, totalPathLength),
        ...blackHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...greenHandCoords.getRange(pathLength * 2, totalPathLength),
        ...greenHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...yellowHandCoords.getRange(pathLength * 2, totalPathLength),
        ...yellowHandCoords.getRange(0, pathLength).toList().reversed,
      ],
      PieceType.red: [
        ...redHandCoords.getRange(0, pathLength * 2),
        ...blackHandCoords.getRange(pathLength * 2, totalPathLength),
        ...blackHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...greenHandCoords.getRange(pathLength * 2, totalPathLength),
        ...greenHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...yellowHandCoords.getRange(pathLength * 2, totalPathLength),
        ...yellowHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...redHandCoords.getRange(pathLength * 2, totalPathLength),
        ...redHandCoords.getRange(0, pathLength).toList().reversed,
      ],
      PieceType.black: [
        ...blackHandCoords.getRange(0, pathLength * 2),
        ...greenHandCoords.getRange(pathLength * 2, totalPathLength),
        ...greenHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...yellowHandCoords.getRange(pathLength * 2, totalPathLength),
        ...yellowHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...redHandCoords.getRange(pathLength * 2, totalPathLength),
        ...redHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...blackHandCoords.getRange(pathLength * 2, totalPathLength),
        ...blackHandCoords.getRange(0, pathLength).toList().reversed,
      ],
      PieceType.green: [
        ...greenHandCoords.getRange(0, pathLength * 2),
        ...yellowHandCoords.getRange(pathLength * 2, totalPathLength),
        ...yellowHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...redHandCoords.getRange(pathLength * 2, totalPathLength),
        ...redHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...blackHandCoords.getRange(pathLength * 2, totalPathLength),
        ...blackHandCoords.getRange(pathLength - 1, pathLength * 2),
        ...greenHandCoords.getRange(pathLength * 2, totalPathLength),
        ...greenHandCoords.getRange(0, pathLength).toList().reversed,
      ],
    };
    if (kDebugMode) {
      // print('totalPathLength: $totalPathLength');
      // print('yellowHandCoords: $yellowHandCoords');
      // print('redHandCoords: $redHandCoords');
      // print('blackHandCoords: $blackHandCoords');
      // print('greenHandCoords: $greenHandCoords');
      // print('length: ${pathCoordinates[PieceType.yellow]?.length}');
      // print('pathCoordinates: $pathCoordinates');
    }

    for (int i = 0; i < playablePieces.length * 4; i++) {
      final piece = playablePieces.elementAt(i ~/ 4);
    }

    currentPlayer = 0;
  }

  void startGame() {
    if (gameState == GameState.playing) return;

    gameState = GameState.playing;
    camera.viewfinder.anchor = Anchor.topLeft;
    final board = Board(
      size: Vector2(boardWidth, boardHeight),
    );
    boardPosition = board.position.xy;
    world.add(board);

    // yellow
    for (var coord in baseCoords) {
      final moveCoord = pathCoordinates[PieceType.yellow]?.elementAt(coord - 1);
      final offset = boardOffsetMap[moveCoord]!;
      world.add(Piece(
        playerId: baseCoords.indexOf(coord),
        type: PieceType.yellow,
        // position: (size.xy / 2) +
        //     Vector2(tileSize / 2, tileSize / 2) * (i + 1.0),
        position: boardPosition + Vector2(offset.dx, offset.dy),
        radius: tileSize / 3,
        index: coord,
      ));
    }

    // red
    for (var coord in baseCoords) {
      final moveCoord = pathCoordinates[PieceType.red]?.elementAt(coord - 1);
      final offset = boardOffsetMap[moveCoord]!;
      world.add(Piece(
        playerId: baseCoords.indexOf(coord),
        type: PieceType.red,
        // position: (size.xy / 2) +
        //     Vector2(tileSize / 2, tileSize / 2) * (i + 1.0),
        position: boardPosition + Vector2(offset.dx, offset.dy),
        radius: tileSize / 3,
        index: coord,
      ));
    }

    // black
    for (var coord in baseCoords) {
      final moveCoord = pathCoordinates[PieceType.black]?.elementAt(coord - 1);
      final offset = boardOffsetMap[moveCoord]!;
      world.add(Piece(
        playerId: baseCoords.indexOf(coord),
        type: PieceType.black,
        // position: (size.xy / 2) +
        //     Vector2(tileSize / 2, tileSize / 2) * (i + 1.0),
        position: boardPosition + Vector2(offset.dx, offset.dy),
        radius: tileSize / 3,
        index: coord,
      ));
    }

    // green
    for (var coord in baseCoords) {
      final moveCoord = pathCoordinates[PieceType.green]?.elementAt(coord - 1);
      final offset = boardOffsetMap[moveCoord]!;
      world.add(Piece(
        playerId: baseCoords.indexOf(coord),
        type: PieceType.green,
        // position: (size.xy / 2) +
        //     Vector2(tileSize / 2, tileSize / 2) * (i + 1.0),
        position: boardPosition + Vector2(offset.dx, offset.dy),
        radius: tileSize / 3,
        index: coord,
      ));
    }

    world.add(DicePair(
      // position: Vector2(width / 2, height / 2),
      position: size / 2 + Vector2(tileSize * 0.9, tileSize * 0.9) * 5.5,
      size: Vector2(diceWidth, diceWidth) * 5,
    ));
  }

  @override
  void onTap() {
    super.onTap();
    startGame();

    // if (gameState == GameState.playing) {
    //   world.children.query<Dice>().forEach((dice) {
    //     dice.roll();
    //   });
    // }
  }

  // fixme: not working correctly for some reason on drag
  // // pinch to zoom in and out or rotate via drag gesture on the screen
  // @override
  // void onDragUpdate(DragUpdateEvent event) {
  //   super.onDragUpdate(event);
  //   // zoom in and out
  //   final delta = event.canvasDelta.xy * 0.01;
  //   final zoom = camera.viewfinder.zoom;
  //   camera.viewfinder.zoom = (zoom + delta.x).clamp(0.5, 2.0);
  //   // rotate
  //   final angle = camera.viewfinder.angle;
  //   camera.viewfinder.angle = (angle + delta.y).clamp(-0.5, 0.5);
  // }

  /// if two pieces are in the same position, then we can separate them
  /// by moving them in opposite directions
  ///
  /// scaling is needed to make it look like the pieces are on top of each other
  @override
  void update(double dt) {
    super.update(dt);

    final pieces = world.children.query<Piece>();
    // if two pieces are in the same position of same type, then we can separate them
    // by moving them in opposite directions
    for (int i = 0; i < pieces.length - 1; i++) {
      final piece1 = pieces[i];
      final piece2 = pieces[i + 1];

      if (piece1.type == piece2.type && piece1.position == piece2.position) {
        // separate them
        final offset = ((piece2.position + Vector2.all(1)) -
                    (piece1.position - Vector2.all(1)))
                .normalized() *
            (tileSize / 3);

        piece1.position += offset;
        piece2.position -= offset;
        piece1.scale *= 0.8;
        piece2.scale *= 0.8;
      }
    }

    // if two pieces are in the same position of different type, then we can remove one of them
    if (collisionPieces.isNotEmpty) {
      if (collisionPieces.length == 2) {
        final piece1 = collisionPieces[0];
        final piece2 = collisionPieces[1];
        if (piece1.type == piece2.type && piece1.position == piece2.position) {
          // separate them
          final offset = ((piece2.position + Vector2.all(1)) -
                      (piece1.position - Vector2.all(1)))
                  .normalized() *
              (tileSize / 3);

          piece1.position += offset;
          piece2.position -= offset;
          piece1.scale *= 0.8;
          piece2.scale *= 0.8;
        } else if (piece1.type != piece2.type) {
          // remove only one of them which is cut by current piece
          if (piece1.index == piece2.index) {
            if (currentPlayer == 0) {
              if (piece1.type == PieceType.yellow) {
                final moveCoord =
                    pathCoordinates[PieceType.yellow]?.elementAt(1 - 1);
                final offset = boardOffsetMap[moveCoord]!;
                piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
              } else if (piece1.type == PieceType.red) {
                final moveCoord =
                    pathCoordinates[PieceType.red]?.elementAt(1 - 1);
                final offset = boardOffsetMap[moveCoord]!;
                piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
              } else if (piece1.type == PieceType.green) {
                final moveCoord =
                    pathCoordinates[PieceType.green]?.elementAt(1 - 1);
                final offset = boardOffsetMap[moveCoord]!;
                piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
              } else if (piece1.type == PieceType.black) {
                final moveCoord =
                    pathCoordinates[PieceType.black]?.elementAt(1 - 1);
                final offset = boardOffsetMap[moveCoord]!;
                piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
              }
            }
          }
        }
      }
      collisionPieces.clear();
    }
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
