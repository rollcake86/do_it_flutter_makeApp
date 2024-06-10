import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeybee/view/main/sub/comment_list.dart';

import '../../../data/constant.dart';
import '../../../data/user.dart';

class CommentPage extends StatefulWidget {
  final DocumentSnapshot<Object?> selectedPost;

  const CommentPage({super.key, required this.selectedPost});

  @override
  State<StatefulWidget> createState() {
    return _CommentPage();
  }
}

class _CommentPage extends State<CommentPage> {
  final TextEditingController _commentEditingController =
      TextEditingController();
  HoneyBeeUser user = Get.find();
  QuerySnapshot<Map<String, dynamic>>? comments ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.hobby!),
      ),
      body: FutureBuilder(
          future: _getFirestoreComments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: CircularProgressIndicator(),
              );
            }
            comments = snapshot.data!;
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.greenAccent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.selectedPost['content']),
                      SizedBox(height: 10,),
                      Text(widget.selectedPost['user'] , style: TextStyle(fontSize: 12),),
                      SizedBox(height: 10,),
                      Text(widget.selectedPost['timestamp']
                          .toDate()
                          .toString()
                          .substring(0, 16), style: TextStyle(fontSize: 10),),
                      SizedBox(height: 10,),
                      widget.selectedPost['image'] != ''
                          ? SizedBox(
                              height: 200,
                              child:
                                  Image.network(widget.selectedPost['image']),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: CommentList(
                    comments: comments!,
                  ),
                )),
                SizedBox(height: 60, child: Row(children: [
                  Expanded(child: TextField(
                    controller: _commentEditingController,
                    keyboardType: TextInputType.emailAddress,
                    expands: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Write your comment here',
                    ),
                    maxLines: null,
                  )),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () async {
                      HoneyBeeUser user = Get.find();
                      final content = _commentEditingController.text.toString();
                      if (content.isEmpty) {
                        return;
                      }
                      final comment = {
                        'user': user.email,
                        'content': content,
                        'timestamp': FieldValue.serverTimestamp(),
                      };
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.selectedPost.id)
                          .collection('comments')
                          .add(comment)
                          .then((value) {
                        Get.snackbar(Constant.APP_NAME, 'comment add');
                        _commentEditingController.clear();
                      });

                      _getFirestoreComments().then((value) {
                        setState(() {
                          comments = value;
                        });
                      });
                    },
                    child: Text('Post'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  )
                ],),),
              ],
            );
          }),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getFirestoreComments() async {
    final comments = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.selectedPost.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .get();
    return comments;
  }
}
