import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyBdIHCblYkTUljGS_hOG3v2qE8001ga-qg",
    appId: "1:442667951131:android:e93b2cf8b5daec86ed04be",
    messagingSenderId: "442667951131",
    projectId: "azzamdomainbackend",
    ),);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Azzam Game 001',
      debugShowCheckedModeBanner: false,
      home: InitialPage(),
    );
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  Color themeColor= const Color.fromRGBO(26, 29, 64, 1);

  @override
  void initState() {
    loadData();
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

  Widget getBody(var actualSize, var size) {
    return Container(
      height: actualSize.height,
      width: actualSize.width,
      color: Colors.white,
      child: Center(
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.white,
          child: Center(
            child: SizedBox(
              height: 250,
              width: 200,
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/atgLogo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50, 
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Loading...",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: Colors.orange,
                          )
                        )
                      ],
                    )
                  )
                ],
              )
            )
          )
        )
      )
    );
  }

  Future<void> loadData() async{
    await Future.delayed(const Duration(seconds: 1));
    String? userName= await DataProvider().getString('user', 'name');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("saved name= $userName");
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> MyHomePage(userName: userName))
    );
  }
  
}


class MyHomePage extends StatefulWidget {
  final String? userName;
  const MyHomePage({super.key, required this.userName});

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

  String info= "-";

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
      body: getBody(actualSize, size, widget.userName)
    );
  }

  Widget getBody(Size actualSize, Size size, String? userName) {
    double defWidth= size.width- radius;
    return Container(
      height: actualSize.height,
      width: actualSize.width,
      color: Colors.black,
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
                getScoreDisplay(size, userName),
                isGameOver? gameOver(size, defWidth) : const SizedBox(height: 0),
              ],
            )
        )
      )
    );
  }

  Widget getScoreDisplay(Size size, String? userName) {
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
                  debugPrint("userName= $userName");
                  if(userName!=null) {
                    if(highestScore> score) {
                        String response= await ApiClient().updateScore(userName, highestScore);
                    }
                    // ignore: use_build_context_synchronously
                    //StaticWidget().getFloatingSnackBar(size, response, context);
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
                  padding: EdgeInsets.all(userName==null? 6 : 12),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green,
                  ),
                  child: Center(
                      child: Text(
                        userName!=null
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

  String info= "-";

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
                  DataProvider().saveString("user", "name", controller.text);
                  debugPrint("userName has been saved");
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
              DataProvider().saveString("user", "name", controller.text);
              debugPrint("userName has been saved");
            },
          ),
        )
    );
  }

  Future<void> submitFunction(String userName, var size) async{
    String? localHScore= await DataProvider().getString("user", "hScore");
    String? response;
    if(localHScore!=null) {
      response= await ApiClient().submitScore(
        userName, 
        userName, 
        int.parse(localHScore==""? "0": localHScore), 
        info
        );
    }
    debugPrint(response);
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
  Color goldColor= const Color.fromRGBO(255, 215, 0, 1);
  Color silverColor= const Color.fromARGB(255, 121, 120, 120);
  Color brassColor= const Color.fromRGBO(225, 192, 110, 1);

  ScoreBoard data= ScoreBoard();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size= MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async{
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context)=> const InitialPage()
          )
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBar(size),
        body: getBody(size),
      )
    );
  }

  AppBar getAppBar(var size) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      toolbarHeight: 56,
      actions: [],
      title: Text(
        "All Scores",
        style: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          color: themeColor
        )
      )
    );
  }

  Widget getBody(var size) {
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.white,
      child: Column(
        children: [
          buildTitle(),
          SizedBox(
            height: size.height- 160,
            width: size.width,
            child: SingleChildScrollView(
              child: StreamBuilder(
                stream: ApiClient().readScores(),
                builder: ((context, snapshot) {
                  if(snapshot.hasData) {
                    final users= sort(snapshot.data!);
                    return Column(
                        children: users.map(buildUser).toList(),
                      );
                      } else {
                        return SizedBox(
                          height: size.height- 160,
                          width: size.width,
                          child: const Center(
                            child: Text(
                              "Belum Ada Score",
                              style: TextStyle(fontSize: 30, color: Colors.grey)
                              )
                          )
                        );
                      }
                  }), 
              )
            )
          )
        ]
        
      )
    );
  }

  Widget buildUser(User user) {
    return SizedBox(
      height: 100,
      width: min(widget.size.width, 600),
      child: Row(
        children: [
          getScoreElement(user.info??"", 0, null),
          getScoreElement(user.name??"", 1, null),
          getScoreElement(user.score.toString(), 2, null),
        ],
      )
    );
  }

  Widget buildTitle() {
    return SizedBox(
      height: 100,
      width: min(widget.size.width, 600),
      child: Row(
        children: [
          getScoreElement("Rank", 0, const Color.fromARGB(255, 5, 50, 87)),
          getScoreElement("Name", 1, const Color.fromARGB(255, 5, 50, 87)),
          getScoreElement("Score", 2, const Color.fromARGB(255, 5, 50, 87)),
        ],
      )
    );
  }

  Widget getScoreElement(String text, int index, Color? color) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: 100,
      width: min(widget.size.width/3, 200),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Colors.black12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: text=="1st Winner" 
            ? goldColor 
            : text=="2nd Winner" 
            ? silverColor 
            : text=="3rd Winner" 
            ?  brassColor 
            : color??Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20
          )
        )
      )
    );
  }

  List<User> sort(List<User> list) {
    if(list.isNotEmpty) {
      list.sort((a, b){ return b.score!.compareTo(a.score!);});
      list[0].info= "1st Winner";
      if(list.length> 1) {
        list[1].info= "2nd Winner";
      }
      if(list.length> 2) {
        list[2].info= "3rd Winner";
      }
      if(list.length> 3) {
        for(int i=3; i< list.length; i++) {
          list[i].info = "${i+1}-th Position";
        }
      }
      return list;
    } else {
      return list;
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

  Future<String> updateScore(String userName, int newScore) async {
    try {
      debugPrint("submitScore is in progress...");
      final docUser= FirebaseFirestore.instance.collection('users').doc(userName);
      await docUser.update({
        "score": newScore
      });
      return "data is submitted successfully";
    } catch(e) {
      return e.toString();
    }
  }

  Future<String> submitScore(String id, String name, int score, String info) async {
    try {
      debugPrint("submitScore is in progress...");
      final docUser= FirebaseFirestore.instance.collection('users').doc();
      final json= {
        "id": docUser.id,
        "name": name,
        "score": score,
        "info": info 
      };
      await docUser.set(json);
      return "data is submitted successfully";
    } catch(e) {
      return e.toString();
    }
  }

  Stream<List<User>> readScores() => FirebaseFirestore.instance
  .collection("users")
  .snapshots()
  .map(
    (snapshot)=> snapshot.docs.map(
      (doc)=> User.fromJson(doc.data())).toList());

}

class User {
 
  String? id;
  final String? name;
  final int? score;
  String? info;

  User({
    this.id= "",
    required this.name,
    required this.score,
    required this.info,
  });

  static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    score: json['score'],
    info: '-'
  );

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