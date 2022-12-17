import 'dart:async';
import 'dart:math';

import 'package:coba/game/objects/bird.dart';
import 'package:coba/game/objects/enemies.dart';
import 'package:flutter/material.dart';

class GameArea extends StatefulWidget {
  const GameArea({Key? key, required this.screenSize}) : super(key: key);
  final Size screenSize;

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  double birdPosition = 0;
  double birdUpPosition = 0;
  int birdDuration = 0;
  double groundHeight = 100;
  int objSize = 30;
  int score = 0;
  List<AnimatedPositioned> objects = [];
  GlobalKey birdKey = GlobalKey();
  List<GlobalKey> enemyBirdKey = [];
  List<double> enemyBirdPosition = [];
  List<bool> enemyBirdVisibility = [];
  double headMove = 0;
  bool gameOver = false;
  bool firstTap = true;
  int tiktok = 0;
  int enemyIndex = 1;
  int totalEnemies = 10;
  int index = -99;

  double _getRandom() {
    Random random = Random();
    int randomPosition = 60 +
        random.nextInt(
            (widget.screenSize.height - groundHeight - objSize).toInt() - 60);
    return randomPosition.toDouble();
  }

  @override
  void initState() {
    setState(() {
      _initGame();
    });
    super.initState();
  }

  _initGame() {
    birdPosition = (widget.screenSize.height - groundHeight) / 2;
    birdDuration =
        (700 + (widget.screenSize.height - groundHeight) - birdPosition)
            .toInt();
    birdUpPosition = 0;
    score = 0;
    objects.clear();
    birdKey = GlobalKey();
    enemyBirdKey.clear();
    enemyBirdPosition.clear();
    enemyBirdVisibility.clear();
    headMove = 0;
    gameOver = false;
    firstTap = true;
    tiktok = 0;
    enemyIndex = 1;
    index = -99;
    objects.add(birdObj());
    for (int i = 0; i < totalEnemies; i++) {
      enemyBirdKey.add(GlobalKey());
      enemyBirdPosition.add(_getRandom());
      enemyBirdVisibility.add(true);
      objects.add(
        enemyBirdObj(
          enemyBirdKey[i],
          enemyBirdVisibility[i],
          (widget.screenSize.width + objSize),
          enemyBirdPosition[i],
        ),
      );
    }
  }

  AnimatedPositioned birdObj() {
    return AnimatedPositioned(
      key: birdKey,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(headMove / 360),
        child: const Bird(),
      ),
      duration: Duration(milliseconds: birdDuration),
      top: birdPosition,
      left: 20,
    );
  }

  AnimatedPositioned enemyBirdObj(
    GlobalKey poisonKey,
    bool visibility,
    double x,
    double y, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return AnimatedPositioned(
      key: poisonKey,
      child: Visibility(
        visible: visibility,
        child: const Enemy(),
      ),
      duration: duration,
      top: y,
      left: x,
    );
  }

  startGame() async {
    setState(() {
      firstTap = false;
      birdPosition = widget.screenSize.height - groundHeight - objSize;
      headMove = 20;
      objects[0] = birdObj();
    });
    play();
  }

  bool _collision(double xOther, double yOther, bool visible) {
    xOther += 15;
    yOther += 15;
    double xMin = getPos(birdKey).dx - 13;
    double xMax = getPos(birdKey).dx + 43;
    double yMin = getPos(birdKey).dy - 13;
    double yMax = getPos(birdKey).dy + 43;
    if (xOther >= xMin &&
        xOther <= xMax &&
        yOther >= yMin &&
        yOther <= yMax &&
        visible) {
      return true;
    }
    return false;
  }

  play() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (getPos(birdKey).dy == birdUpPosition) {
        setState(() {
          birdPosition = widget.screenSize.height - groundHeight - objSize;
          birdDuration = (700 +
                  (widget.screenSize.height - groundHeight) -
                  getPos(birdKey).dy)
              .toInt();
          headMove = 20;
          objects[0] = birdObj();
        });
      }
      setState(() {
        tiktok += 100;
      });
      if (tiktok % 1500 == 0) {
        setState(() {
          tiktok = 0;
          if (enemyIndex > totalEnemies) {
            enemyIndex = 1;
          }
          enemyBirdVisibility[enemyIndex - 1] = true;
          objects[enemyIndex] = enemyBirdObj(
            enemyBirdKey[enemyIndex - 1],
            enemyBirdVisibility[enemyIndex - 1],
            (0.0 - objSize),
            enemyBirdPosition[enemyIndex - 1],
          );
          enemyIndex++;
        });
      }
      for (int i = 0; i < enemyBirdKey.length; i++) {
        if (getPos(enemyBirdKey[i]).dx == (0.0 - objSize)) {
          if (index != i) {
            setState(() {
              index = i;
              score++;
            });
          }
          setState(() {
            enemyBirdPosition[i] = _getRandom();
            enemyBirdVisibility[i] = false;
            objects[i + 1] = enemyBirdObj(
                enemyBirdKey[i],
                enemyBirdVisibility[i],
                (widget.screenSize.width + objSize),
                enemyBirdPosition[i],
                duration: const Duration(milliseconds: 5));
          });
        }
        bool collision = _collision(
          getPos(enemyBirdKey[i]).dx,
          getPos(enemyBirdKey[i]).dy,
          enemyBirdVisibility[i],
        );
        if (collision) {
          collision = false;
          setState(() {
            gameOver = true;
            headMove = 0;
            birdPosition = getPos(birdKey).dy;
            objects[0] = birdObj();
          });
          timer.cancel();
        }
      }
      if (getPos(birdKey).dy ==
          widget.screenSize.height - groundHeight - objSize) {
        setState(() {
          gameOver = true;
          headMove = 0;
          birdPosition = getPos(birdKey).dy;
          objects[0] = birdObj();
        });
        timer.cancel();
      }
    });
  }

  Offset getPos(GlobalKey key) {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  birdMove() {
    setState(() {
      birdPosition = getPos(birdKey).dy - 30;
      birdDuration = 300;
      headMove = 340;
      birdUpPosition = getPos(birdKey).dy - 30;
      objects[0] = birdObj();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: gameOver
          ? () {}
          : () {
              if (firstTap) startGame();
              birdMove();
            },
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - groundHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background-night.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                for (Widget widget in objects) widget,
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "$score",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Visibility(
                    visible: firstTap,
                    child: const Text(
                      "Tap To Start",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Visibility(
                    visible: gameOver,
                    child: Container(
                      width: 200,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        border: Border.all(
                          color: Colors.brown,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/gameover.png"),
                          const Text(
                            "Your Score:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "$score",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: gameOver
                                ? () {
                                    setState(() {
                                      _initGame();
                                    });
                                  }
                                : () {},
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.red,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: groundHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/base.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
