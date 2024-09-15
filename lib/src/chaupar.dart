import 'dart:async';
import 'dart:math';

import 'package:chaupar_chakravyuh/src/services/audio_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'constants/constant.dart';
import 'utils/component_alignment.dart';

typedef Coord = (int, int);

enum GameState { initial, playing, paused, over, won }

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

  Vector2 getBoardPosition(Piece piece) {
    final moveCoord = pathCoordinates[piece.type]?.elementAt(piece.index - 1);
    final offset = boardOffsetMap[moveCoord]!;
    final distination =
        piece.position = boardPosition + Vector2(offset.dx, offset.dy);
    return distination;
  }

  late Vector2 boardPosition;
  late Map<Coord, Offset> boardOffsetMap = {};
  late Map<PieceType, List<Coord>> pathCoordinates = {};
  late int currentPlayer;
  int _currentTurn = 0;

  late List<Piece> collisionPieces = [];
  late AudioService audioService;
  final playablePieces = {
    PieceType.yellow,
    PieceType.red,
    PieceType.black,
    PieceType.green
  };

  bool isNowGameLoopRunable = true;

  int totalRolledValues = 0;

  @override
  bool debugMode = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    audioService = AudioService.instance;

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

    int playerId = 0;
    // add pieces to the board in the correct order
    for (var pieceType in playablePieces) {
      for (var coord in baseCoords) {
        final moveCoord = pathCoordinates[pieceType]?.elementAt(coord - 1);
        final offset = boardOffsetMap[moveCoord]!;
        world.add(
          Piece(
            playerId: playerId++,
            type: pieceType,
            position: boardPosition + Vector2(offset.dx, offset.dy),
            radius: tileSize / 3,
            index: coord,
          ),
        );
      }
    }

    world.add(
      DicePair(
        // position: Vector2(width / 2, height / 2),
        position: size / 2 + Vector2(tileSize * 0.9, tileSize * 0.9) * 5.5,
        size: Vector2(diceWidth, diceWidth) * 5,
      ),
    );
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  // move pieces based on the dices rolled
  void movePiece() {}

  void nextTurn() {
    _currentTurn =
        (_currentTurn + 1) % playablePieces.length; // Cycle through players
    currentPlayer = _currentTurn;
  }

  Future<void> handlePlayerAction() async {
    if (gameState != GameState.playing) return;

    final currentPieceType = playablePieces.elementAt(currentPlayer);
    final pieces = world.children
        .query<Piece>()
        .where((piece) => piece.type == currentPieceType);
    if (pieces.isEmpty) return;
    for (var piece in pieces) {
      if (piece.state == PieceState.won) continue;
      final dice = world.children.query<DicePair>().first;
      totalRolledValues = dice.diceValues.reduce((v, e) => v + e);
      var newPositionIndex = piece.index + totalRolledValues;
      if (piece.canMoveTo(newPositionIndex)) {
        piece.moveableState = PieceMoveableState.movable;
      }
    }

    // if (kDebugMode) {
    //   print('isNextTurn: $isNextTurn');
    // }

    // if (await isNextTurn) {
    //   for (var piece in pieces) {
    //     piece.moveableState = PieceMoveableState.unmovable;
    //   }
    //   nextTurn();
    //   isNextTurn = Future.value(false);
    //   if (kDebugMode) {
    //     print('currentPlayer: $currentPlayer');
    //   }
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
    if (gameState != GameState.playing) return;

    // if (isNowGameLoopRunable) {
    //   isNowGameLoopRunable = false;
    //   final pieces = world.children.query<Piece>().toList();

    //   // check if two pieces are in the same position with same type
    //   // if so, then we can separate them by moving them in opposite directions
    //   // scaling is needed to make it look like the pieces are on top of each other
    //   for (int i = 0; i < pieces.length; i++) {
    //     final piece = pieces[i];
    //     for (int j = 0; j < pieces.length; j++) {
    //       if (i == j) continue;
    //       if (piece.type == pieces[j].type &&
    //           piece.position == pieces[j].position) {

    //       }
    //     }
    //   }

    // }

    if (isNowGameLoopRunable) {
      if (gameState != GameState.playing) return;
      if (kDebugMode) {
        print('isNowGameLoopRunable: $isNowGameLoopRunable in update');
      }
      isNowGameLoopRunable = false;
      final pieces = world.children.query<Piece>().toList();
      if (kDebugMode) {
        print('pieces: $pieces');
      }
      // if multiple pieces are in the same position of same type, then we can separate them
      // by moving them in opposite directions
      final Map<PieceType, List<Piece>> sameTypePieces = {};
      for (int i = 0; i < pieces.length; i++) {
        final piece = pieces[i];
        final samePieces = <Piece>[];
        int skipableIndex = -1;
        for (int j = skipableIndex + 1; j < pieces.length; j++) {
          if (i != j &&
              pieces[j].type == piece.type &&
              pieces[j].position == piece.position) {
            samePieces.add(pieces[i]);
            skipableIndex = i;
          }
        }
        sameTypePieces[piece.type] = samePieces;
      }

      for (var entry in sameTypePieces.entries) {
        if (entry.value.isNotEmpty) {
          // move them in opposite directions

          final noOfSamePieces = entry.value.length;

          List<ComponentAlignment>? alignments = [];
          double scaleFactor = 1;
          if (noOfSamePieces == 1) {
            alignments = [ComponentAlignment.center];
            scaleFactor = 1;
          } else if (noOfSamePieces == 2) {
            alignments = [ComponentAlignment.topLeft, ComponentAlignment.bottomRight];
            scaleFactor = 0.8;
          } else if (noOfSamePieces == 3) {
            alignments = [
              ComponentAlignment.topLeft,
              ComponentAlignment.center,
              ComponentAlignment.bottomRight
            ];
            scaleFactor = 0.6;
          }

          if (kDebugMode) {
            print('alignments.length: ${alignments.length}');
            print('scaleFactor: $scaleFactor');
          }

          for (var i = 0; i < entry.value.length; i++) {
            final samePiece = entry.value[i];
            final alignment = alignments[i % alignments.length];
            samePiece.alignment = alignment;
            samePiece.position +=
                alignment.toVector2.normalized() * (tileSize / 3);
            // Fix scaling: Apply scale factor repeatedly for each overlapping piece
            samePiece.scale =
                Vector2.all(scaleFactor); // Reset to the base scale factor
            samePiece.scale *= pow(0.8, i)
                as double; // Apply additional scaling for each overlap
          }
        }
      }
    }

    // if two pieces are in the same position of different type, then we can remove one of them
    // if (collisionPieces.isNotEmpty) {
    //   if (collisionPieces.length == 2) {
    //     final piece1 = collisionPieces[0];
    //     final piece2 = collisionPieces[1];
    //     if (piece1.type == piece2.type && piece1.position == piece2.position) {
    //       // separate them
    //       final offset = ((piece2.position + Vector2.all(1)) -
    //                   (piece1.position - Vector2.all(1)))
    //               .normalized() *
    //           (tileSize / 3);

    //       piece1.position += offset;
    //       piece2.position -= offset;
    //       piece1.scale *= 0.8;
    //       piece2.scale *= 0.8;
    //     } else if (piece1.type != piece2.type) {
    //       // remove only one of them which is cut by current piece
    //       if (piece1.index == piece2.index) {
    //         if (currentPlayer == 0) {
    //           if (piece1.type == PieceType.yellow) {
    //             final moveCoord =
    //                 pathCoordinates[PieceType.yellow]?.elementAt(1 - 1);
    //             final offset = boardOffsetMap[moveCoord]!;
    //             piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
    //           } else if (piece1.type == PieceType.red) {
    //             final moveCoord =
    //                 pathCoordinates[PieceType.red]?.elementAt(1 - 1);
    //             final offset = boardOffsetMap[moveCoord]!;
    //             piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
    //           } else if (piece1.type == PieceType.green) {
    //             final moveCoord =
    //                 pathCoordinates[PieceType.green]?.elementAt(1 - 1);
    //             final offset = boardOffsetMap[moveCoord]!;
    //             piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
    //           } else if (piece1.type == PieceType.black) {
    //             final moveCoord =
    //                 pathCoordinates[PieceType.black]?.elementAt(1 - 1);
    //             final offset = boardOffsetMap[moveCoord]!;
    //             piece1.position = boardPosition + Vector2(offset.dx, offset.dy);
    //           }
    //         }
    //       }
    //     }
    //   }
    //   collisionPieces.clear();
    // }
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
