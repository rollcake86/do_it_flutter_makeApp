import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crafty/view/main/detail/item_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/item_data.dart';


class LinkPage extends StatelessWidget{
  final String link;

  const LinkPage({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
   print(link);
    Future.delayed(Duration(seconds: 1) ,() async{

      FirebaseFirestore.instance.collection('crafty').doc(link).get().then((value) {
        print(value.data());
        final _selectedPost = ItemData.fromStoreData(value) ;
        Get.off(ItemPage(selectedPost: _selectedPost));
      });
    });
    return const Scaffold(
      body: Center(
        child:Column(children: [
          Text('해당 페이지로 이동중입니다')
        ],mainAxisAlignment: MainAxisAlignment.center,),
      ),
    );
  }
}