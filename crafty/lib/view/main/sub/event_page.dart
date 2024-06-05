import 'package:crafty/data/user.dart';
import 'package:crafty/service/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EventPage();
  }
}

class _EventPage extends State<EventPage>{

  final _firestore = FirebaseFirestore.instance;
  bool _isChecked = false;
  final CraftyUser user = Get.find();
  late AdmobService admobService;
  @override
  void initState() {
    super.initState();
    admobService = AdmobService();
    admobService.createRewardAd();
    Get.lazyPut(() => admobService);
    _firestore.collection('craftyusers').doc(user.email).collection('attendance').doc(DateTime.now().toString().substring(0, 10)).get().then((value) async {
      print(value.data());
      if (value.data() == null) {
        _isChecked = false;
      }else {
        if(mounted){
          setState(() {
            _isChecked = value.data()!['isChecked'];
          });
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(child:
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (!_isChecked) {
                    await _firestore.collection('craftyusers').doc(user.email).collection('attendance').doc(DateTime.now().toString().substring(0, 10)).set({
                      'isChecked': true,
                    });
                    await _firestore.collection('craftyusers').doc(user.email).update({
                      'points': FieldValue.increment(10),
                    });
                    setState(() {
                      _isChecked = true;
                    });
                  }
                },
                child: Text('출석체크'),
              ),
              if (_isChecked) Text('출석체크 완료!')
            ],),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () async {
              admobService.showRewardAd(() async {
                admobService.createRewardAd();
                await _firestore.collection('craftyusers').doc(user.email).update({
                  'points': FieldValue.increment(5),
                });
              });
            },
            child: Text('광고 보고 포인트 얻기'),
          )
        ],
      ),),
    );
  }
}