import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mybudongsan/map/map_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _IntroPage();
  }
}

class _IntroPage extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.data != null){
                if (snapshot.data!) {
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return const MapPage();
                    }));
                  });
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'My 부동산',
                          style: TextStyle(fontSize: 50),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Icon(
                          Icons.apartment_rounded,
                          size: 100,
                        )
                      ],
                    ),
                  );
                } else {
                  return const AlertDialog(
                    title: Text('My 부동산'),
                    content: Text(
                        '지금 인터넷이 연결이 되어있지 않아 부동산 앱을 사용할 수 없습니다. 나중에 다시 실행해 주세요.'),
                  );
                }
              } else {
                return const Center(
                  child: Text('데이터가 없습니다'),
                );
              }
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.none:
              return const Center(
                child: Text('데이터가 없습니다'),
              );
          }
        },
        future: connectCheck(),
      ),
    );
  }

  Future<bool> connectCheck() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}
