import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crafty/data/user.dart';
import 'package:crafty/view/auth/email_login_dialog.dart';
import 'package:crafty/view/main/main_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../data/constant.dart';
import 'email_sign_dialog.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPage createState() => _AuthPage();
}

class _AuthPage extends State<AuthPage> {
  // Firebase Auth 객체 생성
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
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
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User? currentUser = FirebaseAuth.instance.currentUser;
      assert(user.uid == currentUser!.uid);
      print('signInWithGoogle succeeded: $user');
      _signIn(SignType.Google, user.email!, "");
      return googleSignInAccount;
    }
    return null;
  }

  // 이메일과 비밀번호로 회원가입하는 메서드
  void _findPassword() async {
    String email = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('비밀번호 초기화'),
          content: TextFormField(
            decoration: InputDecoration(hintText: 'Enter your email'),
            onChanged: (value) {
              email = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _auth.sendPasswordResetEmail(email: email);
                Get.back();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // 이메일과 비밀번호로 회원가입하는 메서드
  void _signUp(SignType type, String email , String password) async {
    try {
      // createUserWithEmailAndPassword 메서드로 회원가입 요청
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // 성공적으로 회원가입되면 메시지 업데이트
      setState(() {
        Get.snackbar(Constant.APP_NAME, '회원가입 성공');
      });
      _signIn(type, email, password);
    } on FirebaseAuthException catch (e) {
      // 에러 발생시 메시지 업데이트
      setState(() {
        Get.snackbar(Constant.APP_NAME, e.message!);
      });
    }
  }

  // 이메일과 비밀번호로 로그인하는 메서드
  void _signIn(SignType type, String email , String password) async {
    try {
      late User? user;
      if (type == SignType.Email) {
        // signInWithEmailAndPassword 메서드로 로그인 요청
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

      } else{
        final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
        user = authResult.user;
      }

      // 성공적으로 로그인되면 메시지 업데이트
      setState(() {
        Get.snackbar(Constant.APP_NAME, '로그인 성공');
      });

      var token = await FirebaseMessaging.instance.getToken();
      final SharedPreferences preferences =
      await SharedPreferences.getInstance();
      await preferences.setString("id", email);
      await preferences.setString("pw", password);
      await preferences.setString("type", type.name);
      await FirebaseFirestore.instance
          .collection('craftyusers')
          .doc(email)
          .set({
        'email': email,
        'fcm': token,
        'signType': type.name,
        'uid': type == SignType.Email ? _auth.currentUser?.uid : user!.uid,
        'noti': true,
      }).then((value) {
        CraftyUser craftyUser = CraftyUser(email: email, password: password);
        craftyUser.uid = (type == SignType.Email ? _auth.currentUser?.uid : user!.uid)!;
        Get.lazyPut(() => craftyUser);
        // 메인페이지 이동
        Get.off(MainPage());
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        Get.snackbar(Constant.APP_NAME, e.message!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                Constant.APP_NAME,
                style: TextStyle(fontFamily: 'clover', fontSize: 30),
              ),
              Lottie.asset(
                'res/animation/shop.json',
                width: MediaQuery.of(context).size.width / 2,
              ),
              SizedBox(
                height: 20,
              ),
              SignInButton(
                Buttons.email,
                text: "Sign up with Email",
                onPressed: () async {
                  CraftyUser user = await Get.to(SignUpWithEmailPage());
                  if (user != null){
                    _signUp( SignType.Email ,user.email, user.password);
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              SignInButton(
                Buttons.google,
                text: "Sign up with Google",
                onPressed: signInWithGoogle,
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () async {
                  CraftyUser user = await Get.to(LoginWithEmailPage());
                  if (user != null){
                    _signIn( SignType.Email ,user.email, user.password);
                  }
                },
                child: Text('이메일로 로그인하기'),
              ),
              ElevatedButton(
                onPressed: _findPassword,
                child: Text('비밀번호 찾기'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
