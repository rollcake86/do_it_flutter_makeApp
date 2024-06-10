import 'package:classicsound/data/local_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


class UserTagPage extends StatefulWidget{
  final Database database;

  const UserTagPage({super.key, required this.database});
  @override
  State<StatefulWidget> createState() {
    return _UserTagPage();
  }
}

class _UserTagPage extends State<UserTagPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('나의 취향'),),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MusicDatabase(widget.database).getMusic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final data = snapshot.data;
              List<String> tags = List.empty(growable: true);
              data!.forEach((element) {
                var tag = (element['tag'] as String).split(",");
                tags.addAll(tag);
              });
              var mostTag = mostCommonStrings(tags);
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text('당신이 좋아하는 음악의 Tag (순서대로)'),
                SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, color: Colors.yellow , size: 50,),
                      Text(mostTag[0], style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, color: Colors.grey),
                      Text(mostTag[1], style: TextStyle(fontSize: 20),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, color: Colors.brown),
                      Text(mostTag[3] , style: TextStyle(fontSize: 18),),
                    ],
                  ),
              ],),);
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

  List<String> mostCommonStrings(List<String> a) {
    final counts = <String, int>{};
    for (final string in a) {
      counts[string] = (counts[string] ?? 0) + 1;
    }
    final sortedCounts = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostCommonStrings = sortedCounts.map((entry) => entry.key).toList();
    print(mostCommonStrings);
    return mostCommonStrings;
  }
}