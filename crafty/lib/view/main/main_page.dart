import 'dart:convert';

import 'package:crafty/view/main/drawer_widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import 'sub/buy_page.dart';
import 'sub/event_page.dart';
import 'sub/sell_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  var _tapNumber = 0;
  Map<String, dynamic> listData = {
    "1": "setting",
    "2": "license",
    "3": "profile"
  };

  @override
  void initState() {
    super.initState();
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    remoteConfig.fetchAndActivate().then((value) {
      final String order = remoteConfig.getString('list_tile_order');
      if(mounted){
        setState(() {
          listData = const JsonDecoder().convert(order);
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _tapNumber == 0
            ? const Text('사기')
            : _tapNumber == 1
                ? const Text('판매하기')
                : const Text('이벤트'),
      ),
      drawer: DrawerWidget(listData),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tapNumber,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check, color: Colors.black),
            label: 'Buy',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.sell,
              color: Colors.black,
            ),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.event,
              color: Colors.black,
            ),
            label: 'Event',
          ),
        ],
        onTap: (value) {
          setState(() {
            _tapNumber = value;
          });
          FirebaseAnalytics.instance.logEvent(
            name: 'bottom_navigation_tap',
            parameters: {'tab_index': value},
          );
        },
      ),
      body: subPage(_tapNumber),
    );
  }

  subPage(int tapNumber) {
    switch (tapNumber) {
      case 0:
        return const BuyPage();
      case 1:
        return const SellPage();
      case 2:
        return EventPage();
    }
  }
}
