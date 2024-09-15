import 'package:chaupar_chakravyuh/src/components/components.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../chaupar.dart';
import '../constants/constant.dart';
import '../utils/component_alignment.dart';

enum PieceType { black, yellow, red, green }

enum PieceState { initial, moving, cut, placed, removed, won }

enum PieceMoveableState { movable, unmovable }

class Piece extends CircleComponent
    with CollisionCallbacks, TapCallbacks, HasGameRef<Chaupar>, EquatableMixin {
  final int playerId;
  final PieceType type;
  late PieceState state;
  late int index;
  late PieceMoveableState moveableState;
  late ComponentAlignment alignment;

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
    moveableState = PieceMoveableState.unmovable;
    alignment = ComponentAlignment.center;
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

    if (moveableState == PieceMoveableState.movable) {
      _drawDashedCircle(canvas, Colors.brown.shade600, size.x);
    }
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
    if (moveableState == PieceMoveableState.movable) {
      _dashAnimation = (_dashAnimation + dt * 50) % 360;
    }
  }

  Vector2 getBoardPosition() {
    final moveCoord = game.pathCoordinates[type]?.elementAt(index - 1);
    final offset = game.boardOffsetMap[moveCoord]!;
    final distination =
        position = game.boardPosition + Vector2(offset.dx, offset.dy);
    return distination;
  }

  void moveTo(List<Vector2> positions) {
    // Initialize the EffectController
    EffectController moveEffectController = EffectController(duration: 1.0);

    // Loop through the positions and add MoveByEffects
    for (int i = 0; i < positions.length; i++) {
      Vector2 startPosition = position;
      Vector2 endPosition = positions[i];

      // Create a MoveByEffect with the desired duration and easing
      MoveByEffect moveEffect =
          MoveByEffect(endPosition - startPosition, moveEffectController);

      // Add the effect to the piece
      add(moveEffect);
    }
  }

  void moveBy(Vector2 distination) {
    add(
      MoveToEffect(
        distination,
        EffectController(duration: 0.2),
        onComplete: () => onMoveComplete(),
      ),
    );
  }

  void onMoveComplete() {
    if (kDebugMode) {
      print('onMoveComplete');
    }
  }

  // void move(int steps) {
  //   streamSteps(steps).listen((step) {
  void move(int steps) async {
    await for (int step in streamSteps(steps)) {
      if (kDebugMode) {
        print('Moving Piece: $playerId, $type at $step');
      }

      final newPosition = getBoardPosition();
      add(
        MoveToEffect(
          newPosition,
          EffectController(duration: 0.1),
          onComplete: () => onMoveComplete(),
        ),
      );
    // }, onDone: () {
    }
      if (kDebugMode) {
        print('onDone: $playerId, $type');
      }
      game.nextTurn();
      final pieces = game.world.children
          .query<Piece>()
          .where((piece) => piece.type == type);
      for (var piece in pieces) {
        piece.moveableState = PieceMoveableState.unmovable;
      }
      game.isNowGameLoopRunable = true;
      final dice = game.world.children.query<DicePair>().first;
      dice.isRolled = false;
      if (kDebugMode) {
        print('piece move done: $playerId, $type');
      }
      // dice.updateDicePositionBasedOnCurrentPlayer();
    // });
  }

  Future<int> futureTask() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return index++;
  }

  Stream<int> streamSteps(int steps) async* {
    for (int i = 0; i < steps; i++) {
      final stream = Stream<int>.fromFuture(futureTask());
      yield await stream.first;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Piece) {
      if (playerId != other.playerId &&
          type != other.type &&
          type == game.playablePieces.elementAt(game.currentPlayer)) {
        game.collisionPieces.add(other);
        if (kDebugMode) {
          print(
              'Collision with other piece: $playerId, $type : ${other.playerId}, ${other.type}');
          print('collisionPieces ${game.collisionPieces}');
        }
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (kDebugMode) {
      print('onTapDown: $playerId, $type');
    }
    if (moveableState == PieceMoveableState.movable) {
      move(game.totalRolledValues);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (kDebugMode) {
      print('onTapUp: $playerId, $type');
    }
  }

  // check if the piece can move to the given index
  bool canMoveTo(int index) {
    if (kDebugMode) {
      print('canMove  $playerId, $type');
    }

    // moveCoord have last index than set state to won
    if (index - 1 > game.pathCoordinates[type]!.length) {
      return false;
    }
    if (index - 1 == game.pathCoordinates[type]!.length) {
      state = PieceState.won;
    }
    return true;
  }

  @override
  List<Object?> get props => [playerId, type];
}
