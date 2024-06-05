import 'package:cloud_firestore/cloud_firestore.dart';

class Music {

  final String name;
  final String composer;
  final String tag;
  final String category;
  final int size;
  final String type;
  final String downloadUrl;
  final String imageDownloadUrl;

  Music(this.name, this.composer, this.tag, this.category, this.size, this.type,
      this.downloadUrl , this.imageDownloadUrl);

  static Music fromStoreData(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Music(
        data['name'],
        data['composer'],
        data['tag'],
        data['category'],
        data['size'],
        data['type'],
        data['downloadUrl'],
        data['imageDownloadUrl']
    );
  }

  Map<String , dynamic> toMap(){
    Map<String , dynamic> mapMusic = {};
    mapMusic['name'] = name;
    mapMusic['composer'] = composer;
    mapMusic['tag'] = tag;
    mapMusic['category'] = category;
    mapMusic['size'] = size;
    mapMusic['type'] = type;
    mapMusic['downloadUrl'] = downloadUrl;
    mapMusic['imageDownloadUrl'] = imageDownloadUrl;
    return mapMusic;
  }
}
