import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeybee/data/constant.dart';
import 'package:honeybee/data/user.dart';

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHistoryPage();
  }
}

class _MyHistoryPage extends State<MyHistoryPage> {
  final List<dynamic> _searchList = List.empty(growable: true);
  final HoneyBeeUser user = Get.find();

  @override
  void initState() {
    super.initState();
    _getList().then((value) {
      if (mounted) {
        setState(() {
          if (value != null) {
            value.forEach((element) {
              setState(() {
                _searchList.add(element);
              });
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 쓴 글'),
      ),
      body: ListView.builder(
        itemCount: _searchList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
                '${_searchList[index]['content']} , (${_searchList[index]['hobby']})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_searchList[index]['user']),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(_searchList[index]['timestamp']
                        .toDate()
                        .toString()
                        .substring(0, 16)),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('posts')
                            .doc(_searchList[index].id)
                            .delete()
                            .then((value) {
                          Get.snackbar(Constant.APP_NAME, "삭제되었습니다");
                        });
                      },
                      child: Text('삭제하기'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> _getList() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('user', isEqualTo: user.email)
        .get();
    return snapshot.docs;
  }
}
