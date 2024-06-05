import 'package:classicsound/view/setting/license_page.dart';
import 'package:classicsound/view/setting/setting_page.dart';
import 'package:classicsound/view/user/user_page.dart';
import 'package:classicsound/view/user/user_tag_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DrawerWidget extends StatelessWidget{
  DrawerWidget({super.key, required this.database});
  final Database database;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getEmail() async {
    User? user = _auth.currentUser;
    String? email = user?.email;
    return email;
  }

  @override
  Widget build(BuildContext context) {
      return FutureBuilder(future: getEmail(), builder: (context , snapshot) {
        if (snapshot.hasData) {
          return   ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(child: Text('${snapshot.data} 님 환영합니다')),
              ListTile(
                title: const Text('다운로드 받은 뮤직'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return  UserPage( database: database,);
                  }));
                },
              ),
              ListTile(
                title: const Text('나의 취향'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return  UserTagPage(database: database,);
                  }));
                },
              ),
              ListTile(
                title: const Text('설정'),
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return SettingPage(database: database,);
                  }));
                },
              ),
              ListTile(
                title: const Text('라이센스'),
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return SoundLicensePage();
                  }));
                },
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      });
  }
}