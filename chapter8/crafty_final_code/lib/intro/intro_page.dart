import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crafty/data/user.dart';
import 'package:crafty/view/auth/auth_page.dart';
import 'package:crafty/view/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/constant.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _IntroPage();
  }
}

class _IntroPage extends State<IntroPage> {
  Future<bool> _notiPermissionCheck() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _loginCheck() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString("id");
    String? pw = preferences.getString("pw");
    String? type = preferences.getString("type");

    if (id == null || pw == null) {
      return false;
    }

    final FirebaseAuth auth = FirebaseAuth.instance;

    if (type == SignType.Email.name) {
      try {
        await auth.signInWithEmailAndPassword(email: id, password: pw);
        CraftyUser user = CraftyUser(email: id, password: pw);
        user.type = SignType.Email.name;
        user.uid = auth.currentUser!.uid;
        Get.lazyPut(() => user);
        return true;
      } on FirebaseAuthException catch (e) {
        return false;
      }
    } else if (type == SignType.Google.name) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        CraftyUser craftyUseruser = CraftyUser(email: id, password: pw);
        craftyUseruser.type = SignType.Google.name;
        craftyUseruser.uid = user.uid;
        Get.lazyPut(() => craftyUseruser);
        return true;
      } else {
        return false;
      }
    }

    return false;
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
              if (snapshot.data != null) {
                if (snapshot.data!) {
                  _notiPermissionCheck().then((value) {
                    _loginCheck().then((value) {
                      if (value == true) {
                        Future.delayed(const Duration(seconds: 2), () async {
                          Get.snackbar(Constant.APP_NAME, '로그인 되었습니다');
                          CraftyUser user = Get.find();
                          await FirebaseFirestore.instance
                              .collection('craftyusers')
                              .doc(user.email)
                              .update({
                            'loginTimeStamp': FieldValue.serverTimestamp()
                          });
                          Get.off(MainPage());
                          // 메인 페이지 이동
                        });
                      } else {
                        // 로그인 페이지 이동
                        Future.delayed(const Duration(seconds: 2), () {
                          Get.off(AuthPage());
                        });
                      }
                    });
                  });
                  return Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            Constant.APP_NAME,
                            style:
                                TextStyle(fontSize: 50, fontFamily: 'clover'),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Lottie.asset('res/animation/shop.json'),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const AlertDialog(
                    title: Text(Constant.APP_NAME),
                    content: Text(
                        '지금 인터넷이 연결이 되어있지 않아 ${Constant.APP_NAME}를 사용할 수 없습니다.'),
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
