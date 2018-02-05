import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gomoku/main.dart';

class GameSearchDialog extends StatefulWidget {
  @override
  _GameSearchDialogState createState() => new _GameSearchDialogState();
}

class _GameSearchDialogState extends State<GameSearchDialog> {
  final DatabaseReference _gamesRef = FirebaseDatabase.instance.reference().child("games");
  bool _searchFinished = false;

  @override
  Widget build(BuildContext context) {
    return new Container(

    );
  }

  void _startFindingGame() {
    _gamesRef.onValue.listen((Event event) {
      List games = event.snapshot.value;
      if (games.length > 0) {
        _startGame(games[0]);
      }
    });
//    Navigator.of(context).pop();
  }


//  @override
//  void didUpdateWidget(GameSearchDialog oldWidget) {
//    super.didUpdateWidget(oldWidget);
//    print('didUpdate');
//    findGame();
//
//  }

  void _startGame(var game) {

  }

  @override
  void initState() {
    super.initState();
    print('init');
    _startFindingGame();

  }

}
