// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybudongsan/geoFire/geoflutterfire.dart';
import 'package:mybudongsan/geoFire/models/point.dart';

import 'package:mybudongsan/main.dart';
import 'package:http/http.dart' as http;

final client = HttpClient();

void main() {
  final geo = Geoflutterfire();

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

  });


  test('upload Apt', () async {
    uploadAptInfo();
  });

}


Future<void> uploadAptInfos(Geoflutterfire geo) async {
  final response = await http.get(Uri.parse('http://openapi.seoul.go.kr:8088/76514c674e696b69373549756e7667/json/OpenAptInfo/1/300/'));
  if (response.statusCode == 200) {
    final aptInfos = jsonDecode(response.body)['OpenAptInfo'];
    final lists = aptInfos['row'] as List<dynamic>;

    var londonRef = FirebaseFirestore.instance.collection('cities');

    for (var element in lists) {
      var aptInfo = (element as Map<String , dynamic>);
      GeoFirePoint myLocation = geo.point(latitude: double.parse(aptInfo['Y_CODE']), longitude: double.parse(aptInfo['X_CODE']));
      // print(aptInfo['X_CODE']);

      londonRef.add({
        'position': myLocation.data,
        'name': aptInfo['APT_NM'] ,
        'address': aptInfo['DOROJUSO'],
        'ALL_DONG_CO': aptInfo['ALL_DONG_CO'],
        'CNT_PA': aptInfo['CNT_PA'],
        'ALL_HSHLD_CO': aptInfo['ALL_HSHLD_CO'],
        'KAPTMPAREA60': aptInfo['KAPTMPAREA60'],
        'KAPTMPAREA85': aptInfo['KAPTMPAREA85'],
        'KAPTMPAREA135': aptInfo['KAPTMPAREA135'],
        'KAPTMPAREA136': aptInfo['KAPTMPAREA136'],
      });
    }
  } else {
    throw Exception('Failed to load album');
  }
}

Future<void> uploadAptInfo() async {
  final file = await rootBundle.loadString('res/json/apt_test_data.json');

  final jsonObject = jsonDecode(file)['DATA'];
  final jsonList = jsonObject as List<dynamic>;
  var londonRef = FirebaseFirestore.instance.collection('wydmu17me');

  for (var element in jsonList) {
    londonRef.add({
      'deal_ymd': element['deal_ymd'],
      'obj_amt': element['obj_amt'],
      'bldg_area': element['bldg_area'],
      'floor': element['floor'],
    });
  }

}
