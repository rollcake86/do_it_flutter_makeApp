import 'package:crafty/data/user.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../profile/profile_list_page.dart';
import '../profile/profile_page.dart';
import '../setting/setting_page.dart';
import '../sub/license_page.dart';


class DrawerWidget extends StatelessWidget {
  Map<String, dynamic> listData;

  DrawerWidget(this.listData, {super.key});

  CraftyUser user = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.email} 님 환영합니다'),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      // 프로필 페이지로 이동
                      Get.to(ProfilePage());
                    },
                    child: const Text('프로필 확인하기'))
              ],
            ),
          ),
          SizedBox(
            height: 500,
            child: ListView.builder(
              itemCount: listData.length,
              itemBuilder: (BuildContext context, int index) {
                final key = listData.keys.elementAt(index);
                final value = listData[key];
                return ListTile(
                  title: Text(valueChangeString(value)),
                  onTap: () {
                    if(value == 'setting') {
                      Get.to(const SettingPage());
                    } else if (value == 'profile') {
                      Get.to(const ProfileListPage());
                    } else if (value == 'license') {
                      Get.to(const CraftyLicensePage());
                    }
                    FirebaseAnalytics.instance.logEvent(
                      name: 'drawer_tap',
                      parameters: {'drawer_item': value},
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  String valueChangeString(value) {
    if(value == 'setting') {
      return '설정';
    } else if (value == 'profile') {
      return '내 글 리스트';
    } else if (value == 'license') {
      return '라이센스';
    } else {
      return '';
    }
  }
}
