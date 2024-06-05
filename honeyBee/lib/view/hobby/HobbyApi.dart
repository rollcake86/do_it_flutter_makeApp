import 'package:firebase_database/firebase_database.dart';

class HobbyApi {
  static Future<Map<String, String>> getHobbies() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final snapshot = await databaseReference.child('hobby').get();

    final hobbies = <String, String>{};
    final value = snapshot.value;

    if (value is Map) {
      value.forEach((key, value) {
        if(value['showing'] == true) {
          hobbies[value['key']] = value['value'];
        }
      });
    }

    return hobbies;
  }
}
