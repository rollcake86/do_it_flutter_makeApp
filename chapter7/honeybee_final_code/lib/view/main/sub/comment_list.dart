import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentList extends StatefulWidget {
  final QuerySnapshot<Map<String, dynamic>> comments;

  const CommentList({super.key, required this.comments});

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final List<bool> _isExpandedList = [];
  final List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    widget.comments.docs.forEach((element) {
      _isExpandedList.add(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    initList();
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpandedList[index] = isExpanded;
        });
      },
      children: _comments.map((comment) {
        final index = _comments.indexOf(comment);
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(comment['content']),
            );
          },
          body: ListTile(
            title: Text('${comment['user']} ${comment['timestamp'].toDate().toString().substring(0, 16)}'),
          ),
          isExpanded: _isExpandedList[index],
        );
      }).toList(),
    );
  }

  void initList() {
    _comments.clear();
    widget.comments.docs.forEach((element) {
      _comments.add(element.data());
    });
    _isExpandedList.add(false);
  }
}