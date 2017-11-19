import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              onPressed: () => handleTwoPlayersGame(context),
              child: new Text('Two players'),
            ),
          ],
        ),
      ),
    );
  }

  void handleTwoPlayersGame(BuildContext context) {
    Navigator.pushNamed(context, '/local_game_dialog');
  }
}
