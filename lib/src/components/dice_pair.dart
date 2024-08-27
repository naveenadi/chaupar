import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../chaupar.dart';
import '../config.dart';
import 'components.dart';

class DicePair extends PositionComponent
    with TapCallbacks, HasGameReference<Chaupar> {
  DicePair({
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        );

  bool _isPressed = false;

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

  void roll() {
    dice1.roll();
    dice2.roll();
  }

  @override
  void onTapDown(TapDownEvent event) => _isPressed = true;

  @override
  void onTapUp(TapUpEvent event) => _isPressed = false;

  @override
  void onTapCancel(TapCancelEvent event) => _isPressed = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (_isPressed) {
      roll();
      _isPressed = false;
      
      if (game.currentPlayer == 0) {
        final pieces = game.world.children.query<Piece>().where((piece) => piece.type == PieceType.yellow);
        if (kDebugMode) {
          print('pieces: $pieces');
        }
      }

      final moveValue = dice1.value + dice2.value;
      final piece = game.world.children.query<Piece>().first;
      final totalMove = piece.index + moveValue;
      if (kDebugMode) {
        print('totalMove: $totalMove');
      }
      if (totalMove > 84) return;

      if (totalMove == 84) {
        piece.state = PieceState.won;
        piece.position = game.size / 2;
        return;
      }

      piece.state = PieceState.moving;
      piece.index += moveValue;
      final moveCoord = game.pathCoordinates[piece.type]?.elementAt(totalMove - 1);
      final offset = game.boardOffsetMap[moveCoord]!;
      if (totalMove >= 80) {
        if (kDebugMode) {
          print('piece.index: ${piece.index}');
          print('moveCoord: $moveCoord');
          print('offset: $offset');
          print('game.boardPosition: ${game.boardPosition}');
          print('piece.position: ${piece.position}');
          print('piece.radius: ${piece.radius}');
          print(
              'game.boardPosition + Vector2(offset.dx, offset.dy): ${game.boardPosition + Vector2(offset.dx, offset.dy)}');
          print("");
        }
      }
      piece.position = game.boardPosition + Vector2(offset.dx, offset.dy);
    }

    _isPressed = false;
  }
}
