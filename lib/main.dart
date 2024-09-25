import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with TapDetector, HasCollisionDetection {
  @override
  void onTapDown(TapDownInfo info) {
    add(FallingObject(position: info.eventPosition.global));
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkCollisions();
  }

  void checkCollisions() {
    final objects = children.whereType<FallingObject>().toList();
    for (int i = 0; i < objects.length; i++) {
      for (int j = i + 1; j < objects.length; j++) {
        if (objects[i].collidingWith(objects[j])) {
          mergeObjects(objects[i], objects[j]);
          return; // 한 번에 하나의 병합만 처리
        }
      }
    }
  }

  void mergeObjects(FallingObject obj1, FallingObject obj2) {
    final newSize = min(obj1.size.x + 10, FallingObject.maxSize); // 새 상자의 크기
    final newPosition = (obj1.position + obj2.position) / 2;
    final newObject = FallingObject(position: newPosition, size: newSize);
    add(newObject);
    remove(obj1);
    remove(obj2);
  }
}

class FallingObject extends PositionComponent with HasGameRef<MyGame> {
  static const double gravity = 400;
  static const double maxSize = 150; // 최대 상자 크기

  Vector2 velocity = Vector2(0, 0);

  FallingObject({Vector2? position, double size = 50})
      : super(size: Vector2.all(size)) {
    this.position = position ?? Vector2(0, 0);
  }

  bool collidingWith(FallingObject other) {
    return this.toRect().overlaps(other.toRect());
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocity.y += gravity * dt;
    position += velocity * dt;

    if (position.y + size.y > game.size.y) {
      position.y = game.size.y - size.y;
      velocity.y = -velocity.y * 0.6; // 바운스 효과
    }

    if (position.x < 0) {
      position.x = 0;
      velocity.x = -velocity.x * 0.8;
    } else if (position.x + size.x > game.size.x) {
      position.x = game.size.x - size.x;
      velocity.x = -velocity.x * 0.8;
    }
  }

  @override
  void render(Canvas canvas) {
    final hue = (size.x - 50) / 100 * 360; // 크기에 따라 색상 변경
    final color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color,
    );
  }
}
