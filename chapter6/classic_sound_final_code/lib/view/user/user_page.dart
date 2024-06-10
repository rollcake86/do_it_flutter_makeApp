import 'package:classicsound/data/local_database.dart';
import 'package:classicsound/view/main/sound/download_listtile.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/music.dart';


class UserPage extends StatefulWidget{
  final Database database;
  const UserPage({super.key, required this.database});

  @override
  State<StatefulWidget> createState() {
    return _UserPage();
  }
}

class _UserPage extends State<UserPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내가 다운받은 음악'),),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MusicDatabase(widget.database).getMusic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final data = snapshot.data;
              return ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  final music = data[index];
                  return DownloadListTile(music: Music(music['name'], music['composer'], music['tag'], music['category'], music['size'], music['type'], music['downloadUrl'],music['imageDownloadUrl']), database: widget.database,);
                },
              );
            } else {
              return Center(child: Text('No data found'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}