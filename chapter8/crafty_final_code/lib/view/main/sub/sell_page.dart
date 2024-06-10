import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crafty/data/constant.dart';
import 'package:crafty/data/crafty_kind.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../../../data/user.dart';

import 'package:http/http.dart' as http;

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SellPage();
  }
}

class _SellPage extends State<SellPage> {
  final TextEditingController _titleTextEditingController =
      TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _priceEditingController = TextEditingController();
  final TextEditingController _tagtextEditingController =
      TextEditingController();
  CraftyUser user = Get.find();
  XFile? _mediaFile;

  int _selectedItem = 1;
  var _checkbox = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: TextField(
              controller: _titleTextEditingController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '제목을 입력하세요',
              ),
              maxLines: 1,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            height: 150,
            child: TextField(
              controller: _textEditingController,
              keyboardType: TextInputType.emailAddress,
              expands: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '상품 내용을 입력하세요',
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
              controller: _priceEditingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '판매할 가격을 입력하세요',
              ),
              maxLines: null,
            ),
          ),
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
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: DropdownButton(
              value: _selectedItem,
              items: craftyKind.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItem = value!;
                });
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('푸시 전달하기'),
              Switch(
                  value: _checkbox.value,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      _checkbox.value = value;
                    });
                  }),
            ],
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
                  var result = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(Constant.APP_NAME),
                          content: SizedBox(
                            height: 200,
                            child: Column(
                              children: [
                                Text(
                                    '글을 게시하시겠습니까? 10포인트 차감됩니다, 푸시 메세지 전송은 5포인트 추가 차감'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back(result: true);
                              },
                              child: Text('Confirm'),
                            ),
                          ],
                        );
                      });

                  if (result) {
                    bool writeCheck = true;
                    await FirebaseFirestore.instance
                        .collection('craftyusers')
                        .doc(user.email)
                        .get()
                        .then((value) {
                      if (!value.data()!.containsKey('points')) {
                        Get.snackbar(Constant.APP_NAME, '포인트가 없습니다');
                        return;
                      }
                      int point = value['points'];
                      if (_checkbox.isTrue) {
                        if (point >= 15) {
                          FirebaseFirestore.instance
                              .collection('craftyusers')
                              .doc(user.email)
                              .update({
                            'points': FieldValue.increment(-15),
                          });
                        } else {
                          Get.snackbar(Constant.APP_NAME, '포인트가 부족합니다.');
                          writeCheck = false;
                        }
                      } else {
                        if (point >= 10) {
                          FirebaseFirestore.instance
                              .collection('craftyusers')
                              .doc(user.email)
                              .update({
                            'points': FieldValue.increment(-10),
                          });
                        } else {
                          Get.snackbar(Constant.APP_NAME, '포인트가 부족합니다.');
                          writeCheck = false;
                        }
                      }
                    });
                    if(writeCheck == true) {
                      final content = _textEditingController.text.trim();
                      final title = _titleTextEditingController.text.trim();
                      final price = _priceEditingController.text.trim();
                      final tag = _tagtextEditingController.text.trim();
                      if (content.isEmpty) {
                        return;
                      }
                      String downloadurl = '';
                      if (_mediaFile != null) {
                        downloadurl = await uploadFile(File(_mediaFile!.path));
                      }
                      final post = {
                        'id': const Uuid().v1(),
                        'user': user.email,
                        'price': price,
                        'content': content,
                        'title': title,
                        'image': downloadurl,
                        'sell': false,
                        'kind': _selectedItem,
                        'tag': getTag(tag.split(",")),
                        'timestamp': FieldValue.serverTimestamp(),
                      };
                      await FirebaseFirestore.instance
                          .collection('crafty')
                          .add(post)
                          .then((value) {
                        _textEditingController.clear();
                        _priceEditingController.clear();
                        _tagtextEditingController.clear();
                        Get.snackbar(Constant.APP_NAME, '업로드 하였습니다');
                        if (_checkbox.isTrue) {
                          http
                              .post(
                            Uri.parse(
                                'https://us-central1-example-20efe.cloudfunctions.net/sendPostNotification'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(<String, dynamic>{
                              'title': _titleTextEditingController.text.trim(),
                              'link': value.id
                            }),
                          )
                              .then((value) {
                            Get.back();
                          });
                        }
                      });
                    }
                  }
                },
                child: Text('올리기'),
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
