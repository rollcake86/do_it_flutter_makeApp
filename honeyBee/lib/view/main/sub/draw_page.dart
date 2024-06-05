import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../../../data/user.dart';
import 'package:http/http.dart' as http;

class DrawPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DrawPage();
  }
}

class _DrawPage extends State<DrawPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _tagtextEditingController =
      TextEditingController();
  HoneyBeeUser user =  Get.find();
  XFile? _mediaFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    Get.put(user);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.hobby!),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            height: 150,
            child: TextField(
              controller: _textEditingController,
              keyboardType: TextInputType.emailAddress,
              expands: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Write your post here',
              ),
              maxLines: null,
            ),
          ),
          _mediaFile != null
              ? SizedBox(
                  height: 300,
                  child: Image.file(
                    File(_mediaFile!.path),
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Center(
                          child: Text('This image type is not supported'));
                    },
                  ),
                )
              : Container(),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: TextField(
              controller: _tagtextEditingController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '태그를 입력하세요 , 로 구분해요',
              ),
              maxLines: null,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // 이미지 업로드 기능을 추가하세요.
                  final ImagePicker _picker = ImagePicker();
                  final XFile? pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 500,
                    maxHeight: 500,
                    imageQuality: 80,
                  );
                  setState(() {
                    _mediaFile = pickedFile;
                  });
                },
                child: Text('갤러리찾기'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // 이미지 업로드 기능을 추가하세요.
                  final ImagePicker _picker = ImagePicker();
                  final XFile? pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 500,
                    maxHeight: 500,
                    imageQuality: 80,
                  );
                  setState(() {
                    _mediaFile = pickedFile;
                  });
                },
                child: Text('카메라앱'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final hobby = user.hobby;
                  final content = _textEditingController.text.trim();
                  final tag = _tagtextEditingController.text.trim();
                  if (content.isEmpty) {
                    return;
                  }
                  String downloadurl = '';
                  if (_mediaFile != null){
                    downloadurl = await uploadFile(File(_mediaFile!.path));
                  }

                  final post = {
                    'user': user.email,
                    'hobby': hobby,
                    'content': content,
                    'image':downloadurl,
                    'tag': getTag(tag.split(",")),
                    'timestamp': FieldValue.serverTimestamp(),
                  };
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .add(post);
                  _textEditingController.clear();

                  http.post(
                    Uri.parse('https://us-central1-example-20efe.cloudfunctions.net/sendPostNotification'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'hobby': user.hobby!,
                    }),
                  );

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
            ],
          ),
        ],
      ),
    );
  }

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file) async {
    String downloadURL = '';
    try {
      String fileName = basename(file.path);
      Reference reference = storage.ref().child('uploads/$fileName');
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      downloadURL = await taskSnapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print(e.toString());
    }
    return downloadURL;
  }

  getTag(List<String> split) {
    List<String> tags = List.empty(growable: true);
    split.forEach((element) {
      if (element.isNotEmpty) {
        tags.add(element);
      }
    });
    return tags;
  }
}
