import 'dart:math';

import 'package:chaupar_chakravyuh/src/config.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../chaupar.dart';
import 'components.dart';

enum PieceType { black, yellow, red, green }

enum PieceState { initial, moving, cut, placed, removed, won }

class Piece extends CircleComponent
    with  CollisionCallbacks, TapCallbacks, HasGameRef<Chaupar> {
  final int playerId;
  final PieceType type;
  late PieceState state;
  late int index;

  Piece({
    required this.playerId,
    required this.type,
    required this.index,
    required super.position,
    required super.radius,
  }) : super(
          anchor: Anchor.center,
        ) {
    state = PieceState.initial;
    color = pieceColors[type.name]!;
  }

  late Color color;
  late Offset _center;
  double _dashAnimation = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _center = Offset(size.x, size.y) / 2;
    add(CircleHitbox());
  }

  var pieceVelocity = 100.0;

  late Vector2 velocity = (Vector2.zero() * pieceVelocity).normalized();

  void startMoving() {
    state = PieceState.moving;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawPiece(canvas, color);
  }

  void drawPiece(Canvas canvas, Color color) {
    drawCircle(canvas, color);

    _drawDashedCircle(canvas, Colors.brown.shade600, size.x);

  }

  void drawCircle(Canvas canvas, Color color) {
    canvas.drawCircle(
      _center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawDashedCircle(Canvas canvas, Color color, double size) {
    final double radius = size / 2;
    final double centerX = size / 2;
    final double centerY = size / 2;

    // Define the dash pattern
    const double dashLength = 10 * 1.6;
    const double dashSpace = 5 * 1.6;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < 360; i += (dashLength + dashSpace) * 1.6) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius * 1.2),
        radians(i + _dashAnimation), // Starting angle in radians
        radians(dashLength), // Sweep angle (length of the dash)
        false, // Use center point to draw arc (false for stroke)
        paint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _dashAnimation = (_dashAnimation + dt * 50) % 360;
  }

  void moveTo(Vector2 position) {
    this.position = position;
  }

  void move(int diceValue) { 
    velocity = (Vector2.zero() * pieceVelocity).normalized();

    // get both dice values in a list from game world
    // and compare them
    // if they match, then we can move the piece
    // if they don't match, then we can't move the piece

    final diceValues = game.world.children.query<DicePair>().first.diceValues;
    


    state = PieceState.moving;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Piece) {
      if (playerId != other.playerId) {
        game.collisionPieces.add(other);
        print('collisionPieces ${game.collisionPieces}');
      }
      if (kDebugMode) {
        print(
            'Collision with other piece: $playerId, $type : ${other.playerId}, ${other.type}');
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (kDebugMode) {
      print('onTapDown: $playerId, $type');
    }
  }

  @override
  void onTapUp(TapUpEvent event)  {
    super.onTapUp(event);
    if (kDebugMode) {
      print('onTapUp: $playerId, $type');
    }
  }


  bool isValidMove(Vector2 position) {
    return true;
  }

  
}
