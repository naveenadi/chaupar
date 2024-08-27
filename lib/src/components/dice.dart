import 'dart:math';

import 'package:chaupar_chakravyuh/src/components/components.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../chaupar.dart';
import '../config.dart';

enum DiceState { rolled, notRolled }

class Dice extends PositionComponent
    with HasGameReference<Chaupar>, TapCallbacks {
  Dice({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        );

  final Radius cornerRadius;
  final Paint basePaint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;

  final Paint dotPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  int _currentValue = 1;
  int _previousValue = 0;
  Random random = Random();
  int get value => _currentValue;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    angle = 2 * pi * random.nextDouble();
    roll();
  }

  void roll() {
    _currentValue =
        allowedDiceValues.elementAt(random.nextInt(allowedDiceValues.length));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        cornerRadius,
      ),
      basePaint,
    );

    final center = Offset(size.x / 2, size.y / 2);
    drawFace(canvas, dotPaint, center, _currentValue);
  }

  void drawFace(Canvas canvas, Paint paint, Offset center, int value) {
    final dotPositions = getDotPositions(value, center: center);
    for (final position in dotPositions) {
      drawDot(canvas, paint, position.dx, position.dy);
    }
  }

  List<Offset> getDotPositions(int value, {required Offset center}) {
    final dotOffset = size.x / 2;
    const dotOffsetFactor = 0.55;

    switch (value) {
      case 1:
        return [Offset(center.dx, center.dy)];
      case 2:
        return [
          Offset(center.dx, center.dy - dotOffset),
          Offset(center.dx, center.dy + dotOffset),
        ];
      case 5:
        return [
          Offset(center.dx - dotOffset * dotOffsetFactor, center.dx),
          Offset(center.dx + dotOffset * dotOffsetFactor, center.dx),
          Offset(center.dx, center.dy),
          Offset(center.dx - dotOffset * dotOffsetFactor, size.y - center.dx),
          Offset(center.dx + dotOffset * dotOffsetFactor, size.y - center.dx),
        ];
      case 6:
        return [
          Offset(center.dx - dotOffset * dotOffsetFactor, center.dx),
          Offset(center.dx + dotOffset * dotOffsetFactor, center.dx),
          Offset(center.dx - dotOffset * dotOffsetFactor, center.dy),
          Offset(center.dx + dotOffset * dotOffsetFactor, center.dy),
          Offset(center.dx - dotOffset * dotOffsetFactor, size.y - center.dx),
          Offset(center.dx + dotOffset * dotOffsetFactor, size.y - center.dx),
        ];
      default:
        return [];
    }
  }

  void drawDot(Canvas canvas, Paint paint, double x, double y) {
    final dotRadius = size.x / 9;
    canvas.drawCircle(Offset(x, y), dotRadius, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_previousValue != _currentValue) {
      _previousValue = _currentValue;
      // Force a redraw by calling render directly or using other techniques
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.world.children.query<DicePair>().first.onTapDown(event);
  }
}
