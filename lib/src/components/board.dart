import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../chaupar.dart';
import '../config.dart';

class Board extends RectangleComponent with HasGameReference<Chaupar> {
  Board({
    required super.size,
  }) : super(
          position: Vector2(
              (gameWidth - boardWidth) * 0.5, (gameHeight - boardHeight) * 0.5),
        );

  double xOffset = (boardWidth - (boardLayout[0].length * tileSize)) / 2;
  double yOffset = (boardHeight - (boardLayout.length * tileSize)) / 2;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    for (int i = 0; i < boardLayout.length; i++) {
      for (int j = 0; j < boardLayout[i].length; j++) {
        final tileRect = _drawRectangle(
          const Size(tileSize, tileSize),
          Offset(xOffset + j * tileSize, yOffset + i * tileSize),
        );
        game.boardOffsetMap.addAll({
          (j, i): tileRect.center,
        });
      }
    }
  }

  Rect _drawRectangle(Size squareSize, Offset startPoint) {
    Offset endPoint = Offset(
        startPoint.dx + squareSize.width, startPoint.dy + squareSize.height);
    return Rect.fromPoints(startPoint, endPoint);
  }

  void _renderTile(Canvas canvas, int i, int j, int tileType) {
    final rectPaint = Paint()..style = PaintingStyle.stroke;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    if (tileType == 0) return;

    final tileRect = _drawRectangle(
      const Size(tileSize, tileSize),
      Offset(xOffset + j * tileSize, yOffset + i * tileSize),
    );

    final bool isPathColor = pathColorCoords.contains((j, i));

    if (tileType == 1) {
      rectPaint.color = Colors.black;
      fillPaint.color = Colors.transparent;
      if (isPathColor) {
        fillPaint.color = Colors.amberAccent.shade100;
      }
    } else if (tileType == 2) {
      rectPaint.color = Colors.transparent;
      fillPaint.color = Colors.white70;
    } else {
      rectPaint.color = Colors.black;
      fillPaint.color = Colors.transparent;
      if (isPathColor) {
        fillPaint.color = Colors.amberAccent.shade100;
      }
    }

    canvas.drawRect(tileRect, rectPaint);
    canvas.drawRect(tileRect, fillPaint);

    if (tileType == 3) {
      final center = Offset(tileRect.center.dx, tileRect.center.dy);
      canvas.drawLine(
        center.translate(tileSize / 2, tileSize / 2),
        center.translate(-tileSize / 2, -tileSize / 2),
        rectPaint,
      );
      canvas.drawLine(
        center.translate(tileSize / 2, -tileSize / 2),
        center.translate(-tileSize / 2, tileSize / 2),
        rectPaint,
      );
    }
  }

  void _renderBoard(Canvas canvas) {
    for (int i = 0; i < boardLayout.length; i++) {
      for (int j = 0; j < boardLayout[i].length; j++) {
        _renderTile(canvas, i, j, boardLayout[i][j]);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    _renderBoard(canvas);
  }
}
