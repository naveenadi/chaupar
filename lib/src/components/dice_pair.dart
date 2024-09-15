import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../chaupar.dart';
import '../constants/constant.dart';
import '../utils/component_alignment.dart';
import 'components.dart';

class DicePair extends PositionComponent
    with TapCallbacks, HasGameReference<Chaupar> {
  late ComponentAlignment alignment;
  DicePair({
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        ) {
    alignment = ComponentAlignment.center;
  }

  bool isRolled = false;

  late final Dice dice1;
  late final Dice dice2;

  List<int> get diceValues => [dice1.value, dice2.value];

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _createDicePair();
  }

  void _createDicePair() {
    dice1 = _createDice(
        Vector2(diceWidth, diceHeight), size.xy / 2 - Vector2(diceWidth, 0));
    dice2 = _createDice(
        Vector2(diceWidth, diceHeight), size.xy / 2 + Vector2(diceWidth, 0));
    addAll([dice1, dice2]);
  }

  Dice _createDice(Vector2 size, Vector2 position) {
    return Dice(
      size: size,
      cornerRadius: const Radius.circular(diceWidth * 0.2),
      position: position,
    );
  }

// check whose is current player is any of it pieces is moveable
  void nextTurn() {
    if (kDebugMode) {
      print('currentPlayer: ${game.currentPlayer}');
    }

    game.handlePlayerAction();
  }

  void handlePlayerAction() {
    if (game.gameState != GameState.playing) return;

    movePieces();
    game.nextTurn();
  }

  // create a method to move the pieces based on the dice roll.
  void movePieces() {
    final pieceType = game.playablePieces.elementAt(game.currentPlayer);
    final piece = game.world.children
        .query<Piece>()
        .where((piece) => piece.type == pieceType)
        .first;
    if (kDebugMode) {
      print('pieceType: $pieceType');
      print('piece: $piece');
    }

    // Calculate the new position based on the dice roll
    final totalRolledValues = dice1.value + dice2.value;
    var newPositionIndex = piece.index + totalRolledValues;
    if (kDebugMode) {
      print('totalRolledValues: $totalRolledValues');
      print('newPositionIndex: $newPositionIndex');
    }

    if (newPositionIndex > 84) return;
    if (newPositionIndex == 84) {
      piece.state = PieceState.won;
      piece.position = game.size / 2;
      return;
    }
    // Ensure the new position doesn't exceed the path length
    if (newPositionIndex > game.pathCoordinates[piece.type]!.length) {
      newPositionIndex = game.pathCoordinates[piece.type]!.length;
    }
    if (kDebugMode) {
      print('newPositionIndex: $newPositionIndex');
    }

    // // Update the piece's position on the board
    // piece.index = newPositionIndex;

    // // Get the new board position
    // final newBoardPosition = game.getBoardPosition(piece);
    // piece.position = newBoardPosition;

    // // Move the piece to the new position
    // piece.moveBy(newBoardPosition);

    piece.move(totalRolledValues);
    game.isNowGameLoopRunable = true;

    // final List<Vector2> positions = [];
    // for (var i = 0; i < totalRolledValues; i++) {
    //   final moveCoord =
    //       game.pathCoordinates[piece.type]?.elementAt(piece.index);
    //   final offset = game.boardOffsetMap[moveCoord]!;
    //   final distination =
    //       piece.position = game.boardPosition + Vector2(offset.dx, offset.dy);
    //   positions.add(distination);
    //   if (kDebugMode) {
    //     print('piece.index: ${piece.index}');
    //     print('moveCoord: $moveCoord');
    //     print('offset: $offset');
    //     print('game.boardPosition: ${game.boardPosition}');
    //     print('piece.position: ${piece.position}');
    //     print('piece.radius: ${piece.radius}');
    //     print(
    //         'game.boardPosition + Vector2(offset.dx, offset.dy): ${game.boardPosition + Vector2(offset.dx, offset.dy)}');
    //     print("");
    //   }

    //   piece.index += 1;
    // piece.moveTo(positions);
    // }
  }

  void roll() {
    dice1.roll();
    dice2.roll();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.audioService.play(SoundAssets.diceThrow3);
    if (!isRolled) {
      roll();
      isRolled = true;
      game.handlePlayerAction();
    }
  }

  void moveBy(Vector2 distination) {
    add(
      MoveToEffect(
        distination,
        EffectController(duration: 0.2),
      ),
    );
  }

  void updateDicePositionBasedOnCurrentPlayer(double dt) {
    switch (game.currentPlayer) {
      case 0:
        alignment = ComponentAlignment.bottomRight * 0.9;
        position = game.size / 2 +
            Vector2(tileSize * alignment.x, tileSize * alignment.y) * 5.5;
        break;
      case 1:
        alignment = ComponentAlignment.topRight * 0.9;
        position = game.size / 2 +
            Vector2(tileSize * alignment.x, tileSize * alignment.y) * 5.5;
        break;
      case 2:
        alignment = ComponentAlignment.topLeft * 0.9;
        position = game.size / 2 +
            Vector2(tileSize * alignment.x, tileSize * alignment.y) * 5.5;
        break;
      case 3:
        alignment = ComponentAlignment.bottomLeft * 0.9;
        position = game.size / 2 +
            Vector2(tileSize * alignment.x, tileSize * alignment.y) * 5.5;
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateDicePositionBasedOnCurrentPlayer(dt);
  }
}
