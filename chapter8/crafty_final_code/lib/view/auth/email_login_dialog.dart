
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/user.dart';

class LoginWithEmailPage extends StatefulWidget {
  const LoginWithEmailPage({super.key});

  @override
  _LoginWithEmailPage createState() => _LoginWithEmailPage();
}

class _LoginWithEmailPage extends State<LoginWithEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이메일로 로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: Icon(Icons.check),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '패스워드',
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: Icon(Icons.check),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return '패스워드를 입력해주세요';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Get.back(result: CraftyUser(email: _emailController.text.trim() , password:_passwordController.text.trim()));
                    }
                  },
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
