import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crafty/data/item_data.dart';
import 'package:crafty/data/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  final ItemData selectedPost;

  const ChatPage({super.key, required this.selectedPost});

  @override
  State<StatefulWidget> createState() {
    return _ChatPage();
  }
}

class _ChatPage extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  final CraftyUser user = Get.find();
  final _firebase = FirebaseFirestore.instance;


  void _handleSubmitted(String text) {
    _textController.clear();
    _firebase
        .collection('messages')
        .doc(widget.selectedPost.id)
        .set({'timestamp': FieldValue.serverTimestamp()}).then((value) {
      _firebase
          .collection('messages')
          .doc(widget.selectedPost.id)
          .collection('chat')
          .add({
        'user': user.email,
        'comment': text,
        'timestamp': FieldValue.serverTimestamp()
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebase.collection('messages').doc(widget.selectedPost.id).collection('chat').orderBy('timestamp').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('에러발생');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                print("snapshot data ${snapshot.data!.docs}");
                if (snapshot.data! != null) {
                  return SizedBox(height: 800,child: ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      bool isMe = data['user'] == user.email;
                          return Align(
                            alignment:
                                isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.lightBlueAccent
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                data['comment'].toString(),
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          );
                    }).toList(),
                  ), );
                } else {
                  return Text('데이터가 없습니다 첫글을 써보세요');
                }
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _handleSubmitted,
                    decoration: InputDecoration.collapsed(
                      hintText: '메시지를 입력하세요',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
