import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Azzam Game 001',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double yPosition= 100;
  double xPosition= 100;
  double radius= 25;
  double reflectorDx= 10;
  double reflectorXPosition= 0;

  int refMovDir= 1;
  int score= 0;
  int highestScore= 0;

  bool stop= false;
  bool isStarted= false;
  bool isGameOver= false;
  bool isShowingScore= false;

  Velocity velocity= Velocity();

  @override
  void initState() {
    //something to do at initial time
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size= MediaQuery.of(context).size;
    return Scaffold(
      body: getBody(size)
    );
  }

  Widget getBody(Size size) {
    double defWidth= size.width- radius;
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: yPosition- radius,
            left: xPosition- radius,
            child: Container(
              height: 2*radius,
              width: 2*radius,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: Colors.blueGrey
              ),
            )
          ),
          Positioned(
              bottom: 0,
              left: reflectorXPosition,
              child: Container(
                height: 30,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blueGrey
                ),
              )
          ),
          SizedBox(
            height: !stop && !isGameOver? size.height : 0,
            width: size.width,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 200,
                width: size.width- 100,
                child: Row(
                  children: !stop && !isGameOver? [
                    getDirectionButton(size, -1),
                    getDirectionButton(size, 1),
                  ] : [],
                )
              )
            )
          ),
          getButton(size, defWidth),
          getScore(size),
          getScoreDisplay(size),
          isGameOver? gameOver(size, defWidth) : const SizedBox(height: 0),
        ],
      )
    );
  }

  Widget getScoreDisplay(Size size) {
    if(isShowingScore) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isShowingScore= false;
          });
        },
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.black38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                      child: Text(
                        "Latest Score: $score",
                        style: const TextStyle(color: Colors.white, fontSize: 25),
                      )
                  )
              ),
              SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                      child: Text(
                        "Highest Score: $highestScore",
                        style: const TextStyle(color: Colors.white, fontSize: 25),
                      )
                  )
              )
            ],
          )
        )
      );
    } else {
      return const SizedBox(height: 0);
    }
  }

  Widget getScore(Size size) {
    return Positioned(
        top: 30,
        left: 20,
        child: SizedBox(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    splashColor: Colors.black12,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () async{
                      setState(() {
                        isShowingScore= true;
                      });
                      String? localHScore= await getString("user", "hScore");
                      if(localHScore!=null) {
                        highestScore= int.parse(localHScore);
                      }
                    },
                    child: SizedBox(
                        height: 50,
                        width: 150,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Score: $score",
                              style: const TextStyle(color: Colors.black38, fontSize: 25),
                            )
                        )
                    )
                )
            )
        )
    );
  }

  Widget getDirectionButton(Size size, int dir) {
    return SizedBox(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.black12,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: () {
            setState(() {
              refMovDir= dir;
            });
          },
          child: SizedBox(
            height: 200,
            width: (size.width-100)/2,
            child: Center(
              child: Icon(
                dir==1
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios,
                color: Colors.black38,
                size: 30,
              )
            )
          )
        )
      )
    );
  }

  Widget gameOver(Size size, double defWidth) {
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Game Over!",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 20),
          SizedBox(
              child: Material(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                  child: InkWell(
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.black12,
                      onTap: () async{
                        DateTime time= DateTime.fromMillisecondsSinceEpoch(0);
                        setState(() {
                          isStarted= true;
                          isGameOver= false;
                          stop= false;
                          xPosition= radius + time.millisecondsSinceEpoch%defWidth;
                          yPosition= 100;
                          score= 0;
                        });
                        await Future.delayed(const Duration(seconds: 1));
                        startReflectorMoving(size);
                        startMoving(size, defWidth);
                      },
                      child: Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                              child: Text(
                                "Start Over",
                                style: TextStyle(color: Colors.white),
                              )
                          )
                      )
                  )
              )
          )
        ],
      )
    );
  }

  Widget getButton(Size size, double defWidth) {
    return Positioned(
      top: !isStarted? size.height/2 - 25 : 30,
      right: !isStarted? size.width/2 - 75 : 20,
      child: SizedBox(
        child: Material(
          color: !isStarted? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.black12,
            onTap: () async{
              if(isStarted) {
                stopMoving();
              } else {
                setState(() {
                  isStarted= true;
                  isGameOver= false;
                  stop= false;
                });
                await Future.delayed(const Duration(seconds: 1));
                startReflectorMoving(size);
                startMoving(size, defWidth);
              }
            },
            child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                    child: Text(
                      !isStarted? "Start": "Stop",
                      style: const TextStyle(color: Colors.white),
                    )
                )
            )
          )
        )
      )
    );
  }

  Future<void> startReflectorMoving(Size size) async{
    setState(() {
      isStarted= true;
    });
    while(!stop && !isGameOver) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        reflectorXPosition += 10*refMovDir;
      });
      if(refMovDir==1) {
        if(reflectorXPosition+ 100 > size.width) {
          refMovDir= -1;
        }
      } else {
        if(reflectorXPosition< 0) {
          refMovDir= 1;
        }
      }
    }
  }

  Future<void> startMoving(Size size, double defWidth) async{
    double defaultHeight= size.height- 30;
    setState(() {
      isStarted= true;
    });
    while(!stop && !isGameOver) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        yPosition += velocity.dy;
        xPosition += velocity.dx;
      });
      if(yPosition+ radius>defaultHeight) {
        if(xPosition- reflectorXPosition> 0
            && reflectorXPosition+ 100- xPosition> 0
        ) {
          setState(() {
            velocity.verticalReflect(reflectorDx);
            score += 1;
          });
        } else {
          if(score> highestScore) {
            saveString("user", "hScore", score.toString());
          }
          setState(() {
            isGameOver= true;
          });
        }
      }
      if(yPosition- radius< 0) {
        setState(() {
          velocity.verticalReflect(0);
        });
      }
      if(xPosition> defWidth
          || xPosition - radius< 0
      ) {
        velocity.horizontalReflect();
      }
    }
  }

  void stopMoving() {
    setState(() {
      stop= true;
      isStarted= false;
    });
  }

  Future<void> saveString(String userId, String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_generateKey(userId, key), value);
  }

  Future<String?> getString(String userId, String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_generateKey(userId, key));
  }

  String _generateKey(String userId, String key) {
    return '$userId/$key';
  }
}

class Velocity {

  double dx= 10;
  double dy= 10;

  void setVelocity(double dx, double dy) {
    this.dx= dx;
    this.dy= dy;
  }

  void verticalReflect(double rDx) {
    dy= -dy;
    dx -= rDx;
  }

  void horizontalReflect() {
    dx= -dx;
  }
}
