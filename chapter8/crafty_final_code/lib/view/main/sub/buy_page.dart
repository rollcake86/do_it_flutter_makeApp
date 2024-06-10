import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crafty/data/crafty_kind.dart';
import 'package:crafty/data/item_data.dart';
import 'package:crafty/data/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../service/admob_service.dart';
import '../detail/item_page.dart';


class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BuyPage();
  }
}

class _BuyPage extends State<BuyPage> {
  final _scrollController = ScrollController();
  final _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _posts = [];
  bool _loadingPosts = false;
  bool _hasMorePosts = true;
  CraftyUser user = Get.find();

  int _craftyKind = craftyKind.length;

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
      if (_craftyKind!= craftyKind.length) {
        querySnapshot = await _firestore
            .collection('crafty')
            .orderBy('timestamp', descending: true)
            .where('kind' , isEqualTo: _craftyKind+1)
            .limit(10)
            .get();
      } else {
        querySnapshot = await _firestore
            .collection('crafty')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();
      }
    } else {
      if (_craftyKind!= craftyKind.length) {
        querySnapshot = await _firestore
            .collection('crafty')
            .orderBy('timestamp', descending: true)
            .where('kind' , isEqualTo: _craftyKind+1)
            .startAfterDocument(_posts.last)
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
    return Column(children: [
      SizedBox(height: 70,child: ListView.builder( scrollDirection: Axis.horizontal , itemBuilder: (context, index){

        if (index == craftyKind.length) {
          return Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 5),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _craftyKind = index;
                });
                _loadingPosts = false;
                _hasMorePosts = true;
                _posts.clear();
                _getPosts();
              },
              child: Text('전부'),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 5),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _craftyKind = index;
              });
              _loadingPosts = false;
              _hasMorePosts = true;
              _posts.clear();
              _getPosts();
            },
            child: Text((craftyKind[index + 1]) as String),
          ),
        );
      },
          itemCount: craftyKind.length + 1, ),),
      Expanded(child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_hasMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final _selectedPost = ItemData.fromStoreData(_posts[index]) ;
          final email = _selectedPost.user;
          return Center(
            child: Hero(tag: _selectedPost.timestamp, child: Card(
              child: InkWell(
                child: Stack(
                  children: [
                    ListTile(
                      title: Text(_selectedPost.title),
                      subtitle: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${_selectedPost.price}원'),
                                      Text(email.substring(0, email.indexOf('@'))),
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
                                  child: Image.network(_selectedPost.image,
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
                    ) ,
                    _selectedPost.sell == true ?  SizedBox(height: 100, child: Lottie.asset('res/animation/soldout.json'),) : Container()
                  ],
                ),
                onTap: () {
                  // 아이템 상세 페이지로 이동
                  Get.to(ItemPage(selectedPost: _selectedPost));
                },
              ),
            ))

            ,
          );
        },
      ))
    ],);
  }
}
