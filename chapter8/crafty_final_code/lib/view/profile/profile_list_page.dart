import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crafty/data/item_data.dart';
import 'package:crafty/data/user.dart';
import 'package:crafty/view/main/detail/item_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../service/admob_service.dart';

class ProfileListPage extends StatefulWidget {
  const ProfileListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileListPage();
  }
}

class _ProfileListPage extends State<ProfileListPage> {
  final _scrollController = ScrollController();
  final _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _posts = [];
  bool _loadingPosts = false;
  bool _hasMorePosts = true;
  CraftyUser user = Get.find();

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
          .where('user', isEqualTo: user.email)
          .limit(10)
          .get();
    } else {
      querySnapshot = await _firestore
          .collection('crafty')
          .orderBy('timestamp', descending: true)
          .where('user', isEqualTo: user.email)
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
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 쓴 글'),
      ),
      body: ListView.builder(
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
                          trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                            _firestore.collection('crafty').doc(_posts[index].id).delete().then((value) => Get.snackbar("삭제", "삭제되었습니다"));

                          },),
                          leading: IconButton(icon: Icon(Icons.sell), onPressed: (){
                            showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('판매 완료 하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      _firestore.collection('crafty').doc(_posts[index].id).update({'sell':true});
                                      Get.back();
                                    },
                                    child: Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                            );
                          },),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${_selectedPost.price}원'),
                                      Text(email.substring(
                                          0, email.indexOf('@'))),
                                      SizedBox(height: 10),
                                      Text(_selectedPost.timestamp
                                          .toDate()
                                          .toString()
                                          .substring(0, 16)),
                                    ],
                                  )),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: _selectedPost.image != ''
                                        ? SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Image.network(
                                                _selectedPost.image,
                                                fit: BoxFit.cover),
                                          )
                                        : Container(),
                                  ),
                                ],
                              ),
                              ((index + 1) % 5 == 0)
                                  ? AdmobService().showAdBanner()
                                  : Container()
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
      ),
    );
  }
}
