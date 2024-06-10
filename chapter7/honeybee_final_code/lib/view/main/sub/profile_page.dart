import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeybee/data/user.dart';
import 'package:honeybee/view/hobby/HobbySelectionPage.dart';
import 'package:honeybee/view/intro/intro_page.dart';
import 'package:honeybee/view/main/sub/license_page.dart';
import 'package:honeybee/view/main/sub/my_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePage();
  }
}

class _ProfilePage extends State<ProfilePage> {
  bool _hobbyNotification = false;
  bool _postNotification = false;

  HoneyBeeUser user = Get.find();

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  @override
  void dispose() {
    Get.put(user);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Profile'),
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('취미 알림 설정'),
              value: _hobbyNotification,
              onChanged: (value) async {
                setState(() {
                  _hobbyNotification = value;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.email)
                    .update({
                  'hobbyNoti': value
                });
                final SharedPreferences preferences =
                await SharedPreferences.getInstance();
                await preferences.setBool('hobbyNoti', value);
              },
            ),
            SwitchListTile(
              title: Text('내 글 알림 설정'),
              value: _postNotification,
              onChanged: (value) async {
                setState(() {
                  _postNotification = value;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.email)
                    .update({
                  'commentNoti': value
                });
                final SharedPreferences preferences =
                await SharedPreferences.getInstance();
                await preferences.setBool('commentNoti', value);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                  Get.to(MyHistoryPage());
              },
              child: Text('내 글 보기'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(HobbySelectionPage());
              },
              child: Text('취미 변경'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut().then((value) async{
                  final SharedPreferences preferences =
                  await SharedPreferences.getInstance();
                  await preferences.remove("id");
                  await preferences.remove("pw");
                  Get.offAll(IntroPage());
                } );
              },
              child: Text('로그아웃'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Get.to(SNSLicensePage());
              },
              child: Text('오픈소스'),
            ),
          ],
        ));
  }

  void initProfile() async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        _hobbyNotification = preferences.getBool("hobbyNoti")!;
        _postNotification =  preferences.getBool("commentNoti")!;
      });
    }
  }
}
