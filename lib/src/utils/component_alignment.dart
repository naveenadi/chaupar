import 'package:flame/game.dart';

class ComponentAlignment {
  const ComponentAlignment(this.x, this.y);

  final double x;
  final double y;

  /// The top left corner.
  static const ComponentAlignment topLeft = ComponentAlignment(-1.0, -1.0);

  /// The center point along the top edge.
  static const ComponentAlignment topCenter = ComponentAlignment(0.0, -1.0);

  /// The top right corner.
  static const ComponentAlignment topRight = ComponentAlignment(1.0, -1.0);

  /// The center point along the left edge.
  static const ComponentAlignment centerLeft = ComponentAlignment(-1.0, 0.0);

  /// The center point, both horizontally and vertically.
  static const ComponentAlignment center = ComponentAlignment(0.0, 0.0);

  /// The center point along the right edge.
  static const ComponentAlignment centerRight = ComponentAlignment(1.0, 0.0);

  /// The bottom left corner.
  static const ComponentAlignment bottomLeft = ComponentAlignment(-1.0, 1.0);

  /// The center point along the bottom edge.
  static const ComponentAlignment bottomCenter = ComponentAlignment(0.0, 1.0);

  /// The bottom right corner.
  static const ComponentAlignment bottomRight = ComponentAlignment(1.0, 1.0);

  ComponentAlignment operator *(double value) =>
      ComponentAlignment(x * value, y * value);

  Vector2 get toVector2 => Vector2(x, y);

  static List<ComponentAlignment> get alignments => [
        topCenter,
        topRight,
        centerLeft,
        center,
        centerRight,
        bottomLeft,
        bottomCenter,
        bottomRight
      ];
}
