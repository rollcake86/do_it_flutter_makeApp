import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crafty/data/item_data.dart';
import 'package:crafty/view/main/detail/item_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ListPage();
  }
}

class _ListPage extends State<ListPage> {
  final _scrollController = ScrollController();
  final _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _posts = [];
  bool _loadingPosts = false;
  bool _hasMorePosts = true;

  @override
  void initState() {
    super.initState();
    _getPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getPosts();
      }
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
          .collection('crafty')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    } else {
      querySnapshot = await _firestore
          .collection('crafty')
          .orderBy('timestamp', descending: true)
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
        final _selectedPost = ItemData.fromStoreData(_posts[index]);
        final email = _selectedPost.user;
        return Center(
          child: Hero(
              tag: _selectedPost.timestamp,
              child: Card(
                child: InkWell(
                  child: Stack(
                    children: [
                      ListTile(
                        title: Text(_selectedPost.title),
                        leading: ElevatedButton(child: Text('삭제'), onPressed: (){
                          _firestore.collection('crafty').doc(_posts[index].id).delete().then((value) => Get.snackbar("삭제", "삭제되었습니다"));

                        },),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${_selectedPost.price}원'),
                                        Text(email),
                                        SizedBox(height: 10),
                                        Text(_selectedPost.timestamp
                                            .toDate()
                                            .toString()
                                            .substring(0, 16)),
                                      ],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.to(ItemPage(selectedPost: _selectedPost));
                  },
                ),
              )),
        );
      },
    );
  }
}
