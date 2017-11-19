import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomoku/sign_in.dart';
import 'package:gomoku/local_game_dialog.dart';
import 'package:gomoku/menu.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = new GoogleSignIn();
final auth = FirebaseAuth.instance;

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
        '/sign_in': (BuildContext context) => new SignIn(),
        '/local_game_dialog': (BuildContext context) => new LocalGameDialog()
      },
    );
  }


}
