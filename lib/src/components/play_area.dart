import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../chaupar.dart';

class PlayArea extends RectangleComponent with HasGameReference<Chaupar> {
  static const Color playAreaColor = Color(0xfff2e8cf);

  PlayArea()
      : super(
          paint: Paint()..color = playAreaColor,
          children: [RectangleHitbox(collisionType: CollisionType.passive)],
        );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}
