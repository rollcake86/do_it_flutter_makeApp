import 'package:flutter/material.dart';
import 'package:honeybee/view/main/sub/draw_page.dart';
import 'package:honeybee/view/main/sub/home_page.dart';
import 'package:honeybee/view/main/sub/profile_page.dart';
import 'package:honeybee/view/main/sub/search_page.dart';


class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {

  int tapNumber = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: SubPage(tapNumber),),
      bottomNavigationBar: BottomNavigationBar(backgroundColor: Colors.greenAccent, currentIndex: tapNumber, items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search , color: Colors.black,),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.draw, color: Colors.black),
          label: 'Write',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.black),
          label: 'Profile',
        ),
      ], onTap: (value){
          setState(() {
            tapNumber = value;
          });
      },),
    );
  }

  SubPage(int tapNumber) {
    switch(tapNumber){
      case 0:
        return HomePage();
      case 1:
        return SearchPage();
      case 2:
        return DrawPage();
      case 3:
        return ProfilePage();
    }
  }
}