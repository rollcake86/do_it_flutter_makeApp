import 'package:classicsound/data/local_database.dart';
import 'package:classicsound/firebase_options.dart';
import 'package:classicsound/view/intro/intro_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final Database database = await MusicDatabase.initDatabase();
  runApp(MyApp(database: database,));
}


class MyApp extends StatelessWidget {
  final Database database;
  const MyApp({super.key, required this.database});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: IntroPage(database: database,),
    );
  }
}
