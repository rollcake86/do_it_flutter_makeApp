import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeybee/view/hobby/HobbyApi.dart';
import 'package:honeybee/view/main/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/constant.dart';

class HobbySelectionPage extends StatefulWidget {
  const HobbySelectionPage({super.key});

  @override
  _HobbySelectionPageState createState() => _HobbySelectionPageState();
}

class _HobbySelectionPageState extends State<HobbySelectionPage> {
  int _selectedIndex = -1;

  Map<String, String> _hobbies = {};
  final _searchController = TextEditingController();
  String myHobby = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        email = value.getString("id")!;
      });
    });
    HobbyApi.getHobbies().then((value) {
      if (mounted) {
        setState(() {
          _hobbies = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a hobby'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  // 검색 버튼을 눌렀을 때 실행되는 코드
                  final searchQuery = _searchController.text;
                  final snapshot = await FirebaseDatabase.instance
                      .ref()
                      .child('hobby')
                      .orderByChild('value')
                      .startAt(searchQuery)
                      .endAt(searchQuery + '\uf8ff')
                      .once();
                  final hobbies = <String, String>{};
                  final value = snapshot.snapshot.value;
                  if (value is Map) {
                    value.forEach((key, value) {
                      if (value['showing'] == true) {
                        hobbies[value['key']] = value['value'];
                      }
                    });
                  }
                  setState(() {
                    _hobbies = hobbies;
                  });
                },
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: _hobbies.length,
            itemBuilder: (context, index) {
              final entry = _hobbies.entries.elementAt(index);
              final hobby = entry.key;
              final translation = entry.value;
              return ListTile(
                title: Text(hobby),
                subtitle: Text(translation),
                selected: index == _selectedIndex,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  myHobby = hobby;
                  Get.snackbar(Constant.APP_NAME, '$translation를 선택하셨습니다');
                },
              );
            },
          ))
        ],
      ),
      bottomNavigationBar: _selectedIndex != -1
          ? BottomAppBar(
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(email)
                      .update({
                    'hobby': myHobby
                  }).then((value) async {
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    preferences.setString("hobby", myHobby);
                    Get.off(MainPage());
                  });
                },
                child: Text('다음'),
              ),
            )
          : null,
    );
  }
}
