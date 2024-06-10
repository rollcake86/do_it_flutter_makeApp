import 'package:classicsound/data/constant.dart';
import 'package:classicsound/data/music.dart';
import 'package:classicsound/view/main/sound/download_listtile.dart';
import 'package:classicsound/view/main/sound/sound_search_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'drawer_widget.dart';

class MainPage extends StatefulWidget {
  final Database database;
  const MainPage({super.key, required this.database});

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  late List<DocumentSnapshot> documentList =
      List<DocumentSnapshot>.empty(growable: true);
  List<Music> musicList = List<Music>.empty(growable: true);
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    getMusicList();

    dio.options.connectTimeout = 5000; // 5초
    dio.options.receiveTimeout = 3000; // 3초
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constant.APP_NAME),
        actions: [IconButton(onPressed: () async {
          var result = await showDialog(context: context, builder: (context){
            return const MusicSearchDialog();
          });
          if (result != null){
            (result as Query).get().asStream().listen((event) {
              if(mounted){
                setState(() {
                  documentList = event.docs;
                });
              }
            });
          } else {
            getMusicList();
          }
        }, icon: Icon(Icons.search))],
      ),
      drawer:  Drawer(child: DrawerWidget(database: widget.database,)),
      body: ListView.builder(
        itemBuilder: (context, value) {
          Music music = Music.fromStoreData(documentList[value]);
          musicList.add(music);
          return DownloadListTile(music: music, database: widget.database,);
        },
        itemCount: documentList.length,
      ),
    );
  }

  getMusicList() {
    final musicRef = FirebaseFirestore.instance.collection('files');
    musicRef.get().asStream().listen((event) {
      if(mounted){
        setState(() {
          documentList = event.docs;
        });
      }
    });
  }
}
