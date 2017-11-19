import 'package:flutter/material.dart';
import 'package:gomoku/local_game_dialog.dart';
import 'package:gomoku/menu.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new Menu(),
        '/local_game_dialog': (BuildContext context) => new LocalGameDialog()
      },
    );
  }
}
