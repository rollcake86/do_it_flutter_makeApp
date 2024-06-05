import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MusicSearchDialog extends StatefulWidget {
  const MusicSearchDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MusicSearchDialog();
  }
}

class _MusicSearchDialog extends State<MusicSearchDialog> {

  String dropdownValue = 'name';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Music 클래스 검색'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: <String>['name', 'composer', 'tag', 'category']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: '검색어를 입력하세요'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () {
            // 검색 기능 구현
            var result = searchMusicList(searchController.value.text);
            Navigator.of(context).pop(result);
          },
          child: Text('검색'),
        ),
      ],
    );
  }

  Query searchMusicList(String searchKeyword) {
    Query query = FirebaseFirestore.instance.collection('files')
        .where(dropdownValue, isGreaterThanOrEqualTo: searchKeyword)
        .where(dropdownValue, isLessThanOrEqualTo: '$searchKeyword\uf8ff') ;
    return query;
  }
}
