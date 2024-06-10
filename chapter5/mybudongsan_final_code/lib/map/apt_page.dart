import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class AptPage extends StatefulWidget {
  final String aptHash;
  final Map<String, dynamic> aptInfo;

  const AptPage({super.key, required this.aptHash, required this.aptInfo});

  @override
  State<StatefulWidget> createState() {
    return _AptPage();
  }
}

class _AptPage extends State<AptPage> {
  late CollectionReference aptRef;

  @override
  void initState() {
    super.initState();
    aptRef = FirebaseFirestore.instance.collection('wydmu17me');
  }
  int startYear = 2006;
  Icon favoriteIcon = const Icon(Icons.favorite_border);

  @override
  Widget build(BuildContext context) {
    final usersQuery =
        aptRef.orderBy('deal_ymd').where('deal_ymd' , isGreaterThanOrEqualTo: '${startYear}0000') as Query<Map<String, dynamic>>;
    return Scaffold(
      appBar: AppBar(title: Text(widget.aptInfo['name']), actions: [IconButton(onPressed: (){
        FirebaseFirestore.instance.collection('rollcake').doc('favorite').set(widget.aptInfo);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('나의 아파트로 등록되었습니다')));
      }, icon: favoriteIcon)]),
      body:  Column(
          children: [
            Column(children: [
             SizedBox(width: MediaQuery.of(context).size.width ,child:  Text('아파트 이름 : ${widget.aptInfo['name']}'),),
             SizedBox(width: MediaQuery.of(context).size.width ,child:   Text('아파트 주소 : ${widget.aptInfo['address']}'),),
             SizedBox(width: MediaQuery.of(context).size.width ,child:   Text('아파트 동 수 : ${widget.aptInfo['ALL_DONG_CO']}'),),
             SizedBox(width: MediaQuery.of(context).size.width ,child:   Text("아파트 세대 수 : ${widget.aptInfo['ALL_HSHLD_CO']}"),),
             SizedBox(width: MediaQuery.of(context).size.width ,child:   Text('아파트 주차 대수 : ${widget.aptInfo['CNT_PA']}'),),
             SizedBox(width: MediaQuery.of(context).size.width ,child:   Text('60m2 이하 평형 세대수 : ${widget.aptInfo['KAPTMPAREA60']}'),),
             SizedBox(width: MediaQuery.of(context).size.width ,child:   Text('60m2 - 85m2 이하 평형 세대수 : ${widget.aptInfo['KAPTMPAREA85']}'),),
            ],)
            ,Container(color: Colors.black,height: 1, margin: const EdgeInsets.only(top: 5 ,bottom: 5),),
            Text('검색 시작 년도 : $startYear년'),
            Slider(value: startYear.toDouble(), onChanged: (value){
                setState(() {
                  startYear = value.toInt();
                });
            } , min: 2006, max: 2023,),
            Expanded(
                child: FirestoreListView<Map<String, dynamic>>(
              query: usersQuery,
              pageSize: 20,
              itemBuilder: (context, snapshot) {
                Map<String, dynamic> apt = snapshot.data();
                return Card(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text('계약 일시 : ${apt['deal_ymd'].toString()}'),
                          Text('계약 층 : ${apt['floor'].toString()}층'),
                          Text(
                              '계약 가격 : ${double.parse(apt['obj_amt']) / 10000}억'),
                          Text('전용 면적 : ${apt['bldg_area']}m2')
                        ],
                      ),
                      Expanded(child: Container())
                    ],
                  ),
                );
              },
              emptyBuilder: (context) {
                return const Text('매매 데이터가 없습니다');
              },
              errorBuilder: (context, err, stack) {
                return const Text('데이터가 없습니다');
              },
            ))
          ],
      ),
    );
  }
}
