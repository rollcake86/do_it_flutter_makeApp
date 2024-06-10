import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeybee/view/main/sub/comment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  final _scrollController = ScrollController();
  final _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _posts = [];
  bool _loadingPosts = false;
  bool _hasMorePosts = true;
  HoneyBeeUser user = Get.find();
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getPosts();
      }
    });
    SharedPreferences.getInstance().then((value) {
     setState(() {
       user.hobby = value.getString("hobby");
       _getPosts();
       Get.put(user);
     });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _getPosts() async {
    if (!_hasMorePosts || _loadingPosts) {
      return;
    }
    setState(() {
      _loadingPosts = true;
    });
    QuerySnapshot querySnapshot;
    if (_posts.isEmpty) {
      querySnapshot = await _firestore
          .collection('posts')
          .where('hobby', isEqualTo: user.hobby)
          .orderBy('timestamp' , descending: true)
          .limit(10)
          .get();
    } else {
      querySnapshot = await _firestore
          .collection('posts')
          .where('hobby',  isEqualTo: user.hobby)
          .orderBy('timestamp' , descending: true)
          .startAfterDocument(_posts.last)
          .limit(10)
          .get();
    }
    final posts = querySnapshot.docs;
    if (posts.length < 10) {
      _hasMorePosts = false;
    }
    setState(() {
      _loadingPosts = false;
      _posts.addAll(posts);
    });
  }

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      controller: _scrollController,
      itemCount: _posts.length + (_hasMorePosts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _posts.length) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final _selectedPost = _posts[index];
        final email = _selectedPost['user'];
        return Center(
          child: Card(
            child: ListTile(
              title: Text(_selectedPost['content']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email.substring(0, email.indexOf('@'))),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: _selectedPost['image'] != '' ? SizedBox(height: 200, width: 200, child: Image.network(_selectedPost['image'], fit: BoxFit.cover),) : Container(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_selectedPost['timestamp'].toDate().toString().substring(0,16)),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(CommentPage(selectedPost: _posts[index]));
                        },
                        child: Text('Comment'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
