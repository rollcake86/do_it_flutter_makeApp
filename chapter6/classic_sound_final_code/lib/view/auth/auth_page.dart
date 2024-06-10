import 'package:classicsound/data/constant.dart';
import 'package:classicsound/view/main/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AuthPage extends StatefulWidget {
  final Database database;

  const AuthPage({super.key, required this.database});

  @override
  _AuthPage createState() => _AuthPage();
}

class _AuthPage extends State<AuthPage> {
  // Firebase Auth 객체 생성
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 이메일과 비밀번호 입력 컨트롤러 생성
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 인증 상태 메시지
  String _message = '';

  // 이메일과 비밀번호로 회원가입하는 메서드
  void _signUp() async {
    try {
      // createUserWithEmailAndPassword 메서드로 회원가입 요청
      await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      // 성공적으로 회원가입되면 메시지 업데이트
      setState(() {
        _message = '회원가입 성공';
      });
    } on FirebaseAuthException catch (e) {
      // 에러 발생시 메시지 업데이트
      setState(() {
        _message = e.message!;
      });
    }
  }

  // 이메일과 비밀번호로 로그인하는 메서드
  void _signIn() async {
    try {
      // signInWithEmailAndPassword 메서드로 로그인 요청
      await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      // 성공적으로 로그인되면 메시지 업데이트
      setState(() {
        _message = '로그인 성공';
      });
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setString("id", _emailController.text);
      preferences.setString("pw", _passwordController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_emailController.text)
          .set({
        'email': _emailController.text,
        'token': _auth.currentUser?.uid,
      }).then((value) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return MainPage(
            database: widget.database,
          );
        }), (route) => false);
      });
    } on FirebaseAuthException catch (e) {
      // 에러 발생시 메시지 업데이트
      setState(() {
        _message = e.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constant.APP_NAME),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 이메일 입력 필드
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '이메일',
                  hintText: 'example@example.com',
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: Icon(Icons.check),
                ),
              ),
              SizedBox(height: 20,),
              // 비밀번호 입력 필드
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '비밀번호',
                  hintText: '6자 이상',
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: Icon(Icons.check),
                ),
                obscureText: true, // 비밀번호 가리기
              ),
              SizedBox(height: 20,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                // 회원가입 버튼
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('회원가입'),
                ),
                // 로그인 버튼
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('로그인'),
                ),
              ],),
              // 인증 상태 메시지
              Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}
