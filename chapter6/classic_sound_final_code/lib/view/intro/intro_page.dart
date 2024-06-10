import 'dart:async';

import 'package:classicsound/data/constant.dart';
import 'package:classicsound/view/auth/auth_page.dart';
import 'package:classicsound/view/main/main_page.dart';
import 'package:classicsound/view/user/user_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class IntroPage extends StatefulWidget {
  final Database database;
  const IntroPage({super.key, required this.database});

  @override
  State<StatefulWidget> createState() {
    return _IntroPage();
  }
}

class _IntroPage extends State<IntroPage> {

  Future<bool> _loginCheck() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    String? id = preferences.getString("id");
    String? pw = preferences.getString("pw");
    if (id != null && pw != null){
      final FirebaseAuth auth = FirebaseAuth.instance;
      try {
        await auth.signInWithEmailAndPassword(
            email: id, password: pw);
          return true;
      } on FirebaseAuthException catch (e) {
          return false;
      }
    } else {
      return false;
    }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.data != null){
                if (snapshot.data!) {
                   _loginCheck().then((value) {
                     if (value == true) {
                       Future.delayed(const Duration(seconds: 2), () {
                         Navigator.of(context)
                             .pushReplacement(MaterialPageRoute(builder: (context) {
                           return MainPage(database: widget.database,);
                         }));
                       });
                     } else {
                       Future.delayed(const Duration(seconds: 2), () {
                         Navigator.of(context)
                             .pushReplacement(MaterialPageRoute(builder: (context) {
                           return AuthPage(database: widget.database,);
                         }));
                       });
                     }
                   });
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Constant.APP_NAME,
                          style: TextStyle(fontSize: 50),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Icon(
                          Icons.audiotrack,
                          size: 100,
                        )
                      ],
                    ),
                  );
                } else {
                  return AlertDialog(
                    title: Text(Constant.APP_NAME),
                    content: Text(
                        '지금 인터넷이 연결이 되어있지 않아 Classic Sound를 사용할 수 없습니다.'),
                    actions: [
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                            return UserPage(database: widget.database);
                        }), (route) => false);
                      }, child: Text('오프라인으로 사용'))
                    ],
                  );
                }
              } else {
                return const Center(
                  child: Text('데이터가 없습니다'),
                );
              }
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.none:
              return const Center(
                child: Text('데이터가 없습니다'),
              );
          }
        },
        future: connectCheck(),
      ),
    );
  }

  Future<bool> connectCheck() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}
