import 'package:classicsound/data/local_database.dart';
import 'package:classicsound/view/intro/intro_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SettingPage extends StatefulWidget{
  final Database database;
  const SettingPage({super.key, required this.database});

  @override
  State<StatefulWidget> createState() {
    return _SettingPage();
  }
}

class _SettingPage extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final SharedPreferences preferences =
              await SharedPreferences.getInstance();
              await preferences.setString("id" , "");
              await preferences.setString("pw" , "");

              await FirebaseAuth.instance.signOut().then((value) async{
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                  return IntroPage(database: widget.database);
                }), (route) => false);
              } );
            },
            child: Text('Log out'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('데이터 삭제'),
                    content: Text('정말 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('아니오'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('예'),
                      ),
                    ],
                  );
                },
              );
              if (confirm) {
                MusicDatabase(widget.database).deleteMusicDatabase();
              }
            },
            child: Text('데이터 삭제'),
          ),
        ],
      ),
    );
  }
}