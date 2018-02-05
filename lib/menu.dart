import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomoku/main.dart';

class Menu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MenuState();
  }
}

class MenuState extends State<Menu> {
  bool _signingInProgress = false;

  @override
  Widget build(BuildContext context) {
    return _buildMenu();
  }

  Future<FirebaseUser> getUser() async {
    return auth.currentUser();
  }

  Widget _buildMenu() {
    return new Scaffold(
      drawer: _buildDrawer(),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              onPressed: () => handleTwoPlayersGame(),
              child: new Text('Two players'),
            ),
            new FlatButton(
              onPressed: () => handleGameSearch(),
              child: new Text('Play online'),
            ),
          ],
        ),
      ),
    );
  }

  void handleTwoPlayersGame() {
    Navigator.pushNamed(context, '/local_game_dialog');
  }

  void handleGameSearch() {
    Navigator.pushNamed(context, '/game_search');
  }

  Drawer _buildDrawer() {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          _buildDrawerHeader(),
          new ListTile(),
        ],
      ),
    );
  }

  Widget _buildUserActions(FirebaseUser currentUser) {
    String username;
    FlatButton actionButton;
    if (currentUser == null)
      username = "Trying to sign in ...";
    else if (currentUser.isAnonymous) {
      username = "Not signed in";
      actionButton = new FlatButton(
        onPressed: _signingInProgress ? null : handleSignIn,
        child: new Text('Sign in'),
      );
    } else {
      username = currentUser.displayName;
      actionButton = new FlatButton(
        onPressed: _signingInProgress ? null : handleSignOut,
        child: new Text('Sign out'),
      );
    }
    return new Column(
      children: <Widget>[
        new Text(username),
        actionButton == null ? new Container() : actionButton,
      ],
    );
  }

  DrawerHeader _buildDrawerHeader() {
    Widget actions = new FutureBuilder<FirebaseUser>(
      future: getUser(),
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) return _buildUserActions(snapshot.data);
        if (snapshot.hasError) {
          // TODO
          print('ERROR');
          print(snapshot.error.toString());
        }
        return new Container();
      },
    );
    return new DrawerHeader(child: actions);
  }

  void handleSignIn() {
//    setState(() {
//      _signingInProgress = true;
//    });
    Navigator.of(context).pushNamed('/sign_in');
//    setState(() {
//      _signingInProgress = false;
//    });
  }

  void handleSignOut() {
//    setState(() {
//      _signingInProgress = true;
//    });
    Future.wait([auth.signOut(), auth.signInAnonymously()]).then((_) {
      setState(() {});
    });
//    setState(() {
//      _signingInProgress = false;
//    });
  }

  @override
  void initState() {
    super.initState();
    auth.currentUser().then((FirebaseUser user) {
      if (user == null) {
        if (shouldOfferLogin()) {
          Navigator.pushNamed(context, '/sign_in').then((FirebaseUser user) {
            if (user == null) _signInAnonymously();
          });
        } else {
          _signInAnonymously();
        }
      }
      setState(() {});
    });
  }

  void _signInAnonymously() {
    auth.signInAnonymously().then((FirebaseUser user) {
      print('Signed in anonymously');
    });
  }

  bool shouldOfferLogin() {
    return true;
  }
}
