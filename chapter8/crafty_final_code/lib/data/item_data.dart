
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemData{
 final String title;
 final String content;
 final String id;
 final String image;
 final int kind;
 final String price;
 final bool sell;
 final List<dynamic> tag;
 final dynamic timestamp;
 final String user;

  ItemData(this.title , this.content, this.id, this.image, this.kind, this.price, this.sell, this.tag, this.timestamp, this.user);

 static ItemData fromStoreData(DocumentSnapshot snapshot) {
   var data = snapshot.data() as Map<String, dynamic>;
   return ItemData(
       data['title'],
       data['content'],
       data['id'],
       data['image'],
       data['kind'],
       data['price'],
       data['sell'],
       data['tag'],
       data['timestamp'],
       data['user']
   );
 }

 Map<String , dynamic> toMap(){
   Map<String , dynamic> item = {};
   item['title'] = title;
   item['content'] = content;
   item['id'] = id;
   item['image'] = image;
   item['kind'] = kind;
   item['price'] = price;
   item['sell'] = sell;
   item['tag'] = tag;
   item['timestamp'] = timestamp;
   item['user'] = user;
   return item;
 }
}