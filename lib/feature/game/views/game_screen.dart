import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: AwosomeGame(),
      ),
    );
  }
}

class AwosomeGame extends FlameGame {
  late final PlayerPlane plane;
  @override
  Future<void> onLoad() async {
    for (double y = 0; y <= size.y; y += 200) {
      for (double x = 0; x <= size.x; x += 200) {
        add(GameBackground(position: Vector2(x, 0 + y)));
      }
    }
    plane = PlayerPlane(position: Vector2(size.x * 0.5, size.y - 30));
    add(plane);
  }

  double nextSpawnSeconds = 0;
  @override
  void update(dt) {
    super.update(dt);
    nextSpawnSeconds -= dt;
    if (nextSpawnSeconds < 0) {
      add(Bullet(position: plane.position.translated(0, -70)));
      nextSpawnSeconds = 0.1;
    }
  }
}

class GameBackground extends SpriteComponent with HasGameRef {
  GameBackground({
    required position,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('preview.png');
    position = position;
  }
}

class PlayerPlane extends SpriteComponent
    with HasGameRef, CollisionCallbacks, DragCallbacks {
  double nextSpawnSeconds = 0;

  PlayerPlane({
    required position,
  }) : super(position: position, anchor: Anchor.bottomCenter);

  @override
  void onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('player.png');
    position = position;
    size = Vector2(60, 70);
  }

  // @override
  // void update(dt) {
  //   super.update(dt);
  //   nextSpawnSeconds -= dt;
  //   if (nextSpawnSeconds < 0) {
  //     add(Bullet());
  //     nextSpawnSeconds = 0.2;
  //   }
  // }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (position.x + event.localDelta.x < 10 ||
        position.x + event.localDelta.x > gameRef.size.x - 10 ||
        position.y + event.localDelta.y < 100 ||
        position.y + event.localDelta.y > gameRef.size.y) {
      return;
    }
    position += event.canvasDelta;
  }
}

class Bullet extends RectangleComponent with HasGameRef {
  Bullet({required position}) : super(size: Vector2(3, 10), position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    paint.color = Colors.yellow;
    // position = Vector2(30, 0);
    anchor = Anchor.topCenter;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y = position.y - 5;
    if (position.y - size.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}
