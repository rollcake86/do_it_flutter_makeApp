import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'comment_page.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPage();
  }
}

class _SearchPage extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  final List<dynamic> _searchList = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(hintText: '검색할 테그를 입력하세요'),
                ),
              ),
              IconButton(
                onPressed: () {
                  final query = _runFilter(_searchController.text.trim());
                  // query.asStream().map((event) => print(event!.length));
                  _searchList.clear();
                  query.then((value) {
                    if (value != null) {
                      value.forEach((element) {
                        print(element.data());
                        setState(() {
                          _searchList.add(element);
                        });
                      });
                    }
                  });
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('${_searchList[index]['content']} , (${_searchList[index]['hobby']})'),
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
                              Get.to(CommentPage(
                                  selectedPost: _searchList[index]));
                            },
                            child: Text('Comment'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> _runFilter(
      String enteredKeyword) async {

    if (enteredKeyword.isEmpty) {
      return null;
    }
    var snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('tag', arrayContains: enteredKeyword)
        .get();
    return snapshot.docs;
  }
}
