import 'package:flutter/material.dart';
import 'package:gomoku/local_game.dart';
import 'package:gomoku/time_control.dart';

class LocalGameDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LocalGameDialogState();
  }
}

class LocalGameDialogState extends State<LocalGameDialog> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              onPressed: () => handleNewGame(context),
              child: new Text('Play!'),
            ),
          ],
        ),
      ),
    );
  }

  void handleNewGame(BuildContext context) {
    Navigator.of(context).pushReplacement(new PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return new LocalGame(new TimeControl(new Duration(seconds: 30), new Duration(seconds: 5)));
        },
    ));
  }
}
