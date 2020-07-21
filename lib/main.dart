import 'package:ai_first_project/Modules/PuzzleGame.dart';
import 'package:ai_first_project/Pages/mainpanel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PuzzleGame(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '8 Puzzle',
        theme: ThemeData(
          fontFamily: 'Raleway',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MainPanel(),
      ),
    );
  }
}
