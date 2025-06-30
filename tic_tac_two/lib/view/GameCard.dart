import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' as flutter;

class GameCard extends PositionComponent with DragCallbacks {
  /// Creates a draggable GameCard with custom visual data.
  ///
  /// Provided a child, the [GameCard] renders a draggable card
  /// which can be linked to data using [id]

  final int id;
  final String text;
  late Vector2 pointerOffset;

  late TextComponent<TextPaint> label;

  GameCard(
    Vector2? position,
    Vector2? size, {
    required this.text,
    required this.id,
  }) : super(position: position, size: size ?? Vector2(0, 0));

  @override
  FutureOr<void> onLoad() {
    label =
        TextComponent(
            text: text,
            textRenderer: TextPaint(
              style: flutter.TextStyle(
                color: flutter.Colors.red,
                fontSize: 70,
                fontWeight: flutter.FontWeight.bold,
              ),
            ),
          )
          ..anchor = Anchor.center
          ..position = size / 2;

    add(label);
  }

  @override
  void render(Canvas canvas) {
    //canvas.drawColor(flutter.Colors.black, BlendMode.color);

    final paint = flutter.Paint()
      ..color = flutter.Colors.white
      ..style = flutter.PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    super.render(canvas);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.canvasDelta;
  }
}
