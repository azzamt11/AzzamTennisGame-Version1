import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  Color themeColor= const Color.fromRGBO(26, 29, 64, 1);

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
  bool scoreIsSubmitted= false;

  Velocity velocity= Velocity();

  @override
  void initState() {
    //something to do at initial time
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var actualSize= MediaQuery.of(context).size;
    Size size= Size(
      min(actualSize.width, 600),
      actualSize.height,
    );
    return Scaffold(
      body: getBody(actualSize, size)
    );
  }

  Widget getBody(Size actualSize, Size size) {
    double defWidth= size.width- radius;
    return Container(
      height: actualSize.height,
      width: actualSize.width,
      color: themeColor,
      child: Center(
        child: Container(
            height: size.height,
            width: size.width,
            color: Colors.white,
            child: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  width: size.width,
                  child: const Center(
                      child: Text(
                        "Developed By: Abdullah Azzam",
                        style: TextStyle(fontSize: 25, color: Colors.black12),
                      )
                  ),
                ),
                Positioned(
                    top: yPosition- radius,
                    left: xPosition- radius,
                    child: Container(
                      height: 2*radius,
                      width: 2*radius,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          color: themeColor
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
                          color: themeColor
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
        )
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
          color: const Color.fromRGBO(255, 255, 255, 0.75),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                      child: Text(
                        "Latest Score: $score",
                        style: TextStyle(
                          color: themeColor, 
                          fontSize: 25, 
                          fontWeight: FontWeight.bold
                        ),
                      )
                  )
              ),
              SizedBox(
                  height: 50,
                  width: 200,
                  child: Center(
                      child: Text(
                        "Highest Score: $highestScore",
                        style: const TextStyle(
                          color: Color.fromRGBO(26, 29, 64, 1), 
                          fontSize: 25, 
                          fontWeight: FontWeight.bold
                        ),
                      )
                  )
              ),
              GestureDetector(
                onTap: () async{
                  String? userName= await DataProvider().getString("user", "name");
                  if(userName!=null) {
                    String response= await ApiClient().submitScore({
                      "title": "atg001-hs",
                      "body": "$highestScore",
                      "author": userName 
                    });
                    // ignore: use_build_context_synchronously
                    StaticWidget().getFloatingSnackBar(size, response, context);
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context)=> ScorePage(size: size))
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context)=> const SubmitScorePage())
                    );
                  }
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green,
                  ),
                  child: Center(
                      child: Text(
                        scoreIsSubmitted
                        ? "see others scores"
                        : "Submit your highest score and see others scores",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 17,
                        ),
                      )
                  )
                )
              ),
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
                      String? localHScore= await DataProvider().getString("user", "hScore");
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
                              style: const TextStyle(color: Colors.black54, fontSize: 20),
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
                        DateTime time= DateTime.now();
                        double xRange= time.millisecondsSinceEpoch
                        %(defWidth-radius);
                        setState(() {
                          isStarted= true;
                          isGameOver= false;
                          stop= false;
				  velocity= Velocity();
                          xPosition= radius + xRange;
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
        if(xPosition- reflectorXPosition> -5
            && reflectorXPosition+ 100- xPosition> 0
        ) {
          setState(() {
            velocity.verticalReflect(reflectorDx);
            score += 1;
          });
        } else {
          if(score> highestScore) {
            DataProvider().saveString("user", "hScore", score.toString());
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
        velocity.horizontalReflect(
          xPosition, 
          size.width,
          radius
        );
      }
    }
  }

  void stopMoving() {
    setState(() {
      stop= true;
      isStarted= false;
    });
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
    if(dx< 30 && dx> -30) {
      dx -= rDx;
    }
  }

  void horizontalReflect(double x, double width, double radius) {
    dx= -dx;
    if(x + radius> width) {
      dx=  min(dx, -dx);
    }
  }
}

class SubmitScorePage extends StatefulWidget {
  const SubmitScorePage({super.key});

  @override
  State<SubmitScorePage> createState() => _SubmitScorePageState();
}

class _SubmitScorePageState extends State<SubmitScorePage> {
  Color themeColor= const Color.fromRGBO(26, 29, 64, 1);
  
  TextEditingController controller= TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: getBody(size),
    );
  }

  Widget getBody(Size size) {
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: Center(
        child: SizedBox(
          height: 100,
          width: size.width- 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 2),
                height: 35,
                width: size.width- 170,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: themeColor),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: inputTextField(size, "Enter Your Nickname", controller)
              ),
              GestureDetector(
                onTap: () async{
                  await submitFunction(controller.text, size);
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green,
                  ),
                  child: const Center(
                      child: Text(
                        "Submit Score",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 17,
                        ),
                      )
                  )
                )
              ),
            ],
          )
        )
      )
    );
  }

  Widget inputTextField(var size, String string, controller) {
    return(
        SizedBox(
          height: 28,
          child: TextField(
            autofocus: true,
            cursorHeight: 25,
            cursorWidth: 1,
            cursorColor: Colors.black,
            controller: controller,
            style: const TextStyle(fontSize: 15, height: 1.8),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(bottom: 1, top: 5),
              alignLabelWithHint: true,
              isDense: true,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.7),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: string
            ),
            onSubmitted: (value){
              submitFunction(controller.text, size);
            },
          ),
        )
    );
  }

  Future<void> submitFunction(String userName, var size) async{
    String? localHScore= await DataProvider().getString("user", "hScore");
    String? response;
    if(localHScore!=null) {
      response= await ApiClient().submitScore({
        "title": "atg001-hs",
        "body": localHScore,
        "author": userName 
      });
    }
    // ignore: use_build_context_synchronously
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context)=> ScorePage(size: size))
    );
  }

}


class ScorePage extends StatefulWidget {
  final Size size;
  const ScorePage({super.key, required this.size});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  Color themeColor= const Color.fromRGBO(26, 29, 64, 1);

  ScoreBoard data= ScoreBoard();

  @override
  void initState() {
    initiatePeriodicInspection(widget.size);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size= MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: getBody(size)
    );
  }

  Widget getBody(var size) {
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Text(
                "All Scores",
                style: TextStyle(fontSize: 25, color: themeColor),
              ),
            ),
            SizedBox(
              width: size.width,
              child: Column(
                children: getScoreList(data, size),
              )
            )
        ],
      )
      )
    );
  }

  List<Widget> getScoreList(ScoreBoard data, var size) {
    debugPrint("getScoreList with data= ${data.list.first?.name}");
    List<Widget> board= [
      SizedBox(
          height: 40,
          width: min(size.width- 50, 350),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getSubItemWidget(size, "Name", true),
              getSubItemWidget(size, "Score", true),
            ],
          )
        )
    ];
    for(int i=0; i< data.list.length; i++) {
      board.add(
        SizedBox(
          height: 40,
          width: min(size.width- 50, 350),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getSubItemWidget(size, data.list[i]?.name??"", false),
              getSubItemWidget(size, data.list[i]?.score??"", false)
            ],
          )
        )
      );
    }
    return board;
  }

  Widget getSubItemWidget(var size, String text, bool isBold) {
    debugPrint("getSubItemWidget with text= $text");
    return SizedBox(
      height: 40,
      width: size.width/2- 25,
      child: Center(
        child: Text(
          text, 
          style: TextStyle(
            color: themeColor,
            fontSize: 17,
            fontWeight: isBold 
              ? FontWeight.bold 
              : FontWeight.normal,
          )
        ),
      )
    );
  }

  Future<void> initiatePeriodicInspection(var size) async{
    while(true) {
      ScoreBoard newData= await ApiClient().getScores();
      if(newData.list.length!=data.list.length) {
        setState(() {
          data= newData;
        });
        debugPrint("condition 1 is satisfied, data.length= ${data.list.length}");
      } else {
        debugPrint("condition 2 is satisfied, data.length= ${data.list.length}");
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }

}

class StaticWidget {
  Color themeColor= const Color.fromRGBO(26, 29, 64, 1);

  void getFloatingSnackBar(var size, String string, BuildContext context) {
    SnackBar floatingSnackBar = SnackBar(
      content: Text(string, textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      backgroundColor: themeColor,
      margin: EdgeInsets.only(
        bottom: size(size.height/2)- 40, 
        left: size.width/2- 100, 
        right: size.width/2- 100
      ),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(floatingSnackBar);
  }
}

class DataProvider {

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

class ApiClient {

  Future<String> submitScore(Map<String, String> body) async {
    try {
      debugPrint("submitScore is in progress...");
      var response = await http.post(
          Uri.parse("https://azzamtennisgamebe.000webhostapp.com/insert.php"),
          headers: {
            "Content-type": "application/json",
            "Access-Control-Allow-Origin": "*"
          },
          body: json.encode(body)
      );
      debugPrint("response= $response");
      var decodedResponse = json.decode(response.body);
      if (response.statusCode==200) {
        return decodedResponse['message'];
      } else {
        return "Cannot submit data";
      }
    } catch(e) {
      debugPrint("got error 1= $e");
      return e.toString();
    }
  }

  Future<ScoreBoard> getScores() async {
    ScoreBoard scoreBoard= ScoreBoard();
    debugPrint("getScores is in progress...");
    try {
      var response = await http.get(
          Uri.parse("https://azzamtennisgamebe.000webhostapp.com/"),
          headers: {
            "Content-type": "application/json",
            "Access-Control-Allow-Origin": "*"
          },  
      );
      var decodedResponse = json.decode(response.body.split(">").last);
      if (response.statusCode==200) {
        for(int i=0; i< decodedResponse.length; i++) {
          if(decodedResponse[i]["title"]=="atg001-hs") {
            User user= User();
            user.setData(decodedResponse[i]);
            scoreBoard.addData(user);
          }
        }
        debugPrint("scoreBoard= ${scoreBoard.list.first?.name}");
        return scoreBoard;
      } else {
        scoreBoard.setError("Terdapat kesalahan pada server");
        return scoreBoard;
      }
    } catch(e) {
      debugPrint("got error 2= $e");
      scoreBoard.setError(e.toString());
      return scoreBoard;
    }
  }

}

class User {
 
  String? name;
  String? score;
  String? addInf;

  void setData(Map<String, dynamic> data) {
    name= data['author'];
    score= data['body'].toString().split("%%").first;
  }

}

class ScoreBoard {

  List<User?> list= [];

  String? error;

  void addData(User user) {
    list.add(user);
  }

  void setError(String error) {
    this.error= error;
  }

}