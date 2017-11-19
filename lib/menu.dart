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
    return new FutureBuilder<Widget>(
      future: _buildMenuSafe(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Container();
          default:
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return new Text(snapshot.error.toString());
            }
            return snapshot.data;
        }
      },
    );
  }

  Future<Widget> _buildMenuSafe() async {
    try {
      return await _buildMenu();
    } on Exception catch (e) {
      print('sdofijsdfjodsi');
      print(e.toString());
      return null;
    }
  }

  Future<Widget> _buildMenu() async {
    return new Scaffold(
      drawer: await _buildDrawer(),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              onPressed: () => handleTwoPlayersGame(),
              child: new Text('Two players'),
            ),
          ],
        ),
      ),
    );
  }

  void handleTwoPlayersGame() {
    Navigator.pushNamed(context, '/local_game_dialog');
  }

  Future<Drawer> _buildDrawer() async {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          await _buildDrawerHeader(),
          new ListTile(),
        ],
      ),
    );
  }

  Future<DrawerHeader> _buildDrawerHeader() async {
    FirebaseUser currentUser = await auth.currentUser();
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
    return new DrawerHeader(
      child: new Column(
        children: <Widget>[
          new Text(username),
          actionButton == null ? new Container() : actionButton,
        ],
      ),
    );
  }

  Future handleSignIn() async {
    setState(() {
      _signingInProgress = true;
    });
    await Navigator.of(context).pushNamed('/sign_in');
    setState(() {
      _signingInProgress = false;
    });
  }

  Future handleSignOut() async {
    setState(() {
      _signingInProgress = true;
    });
    await auth.signOut();
    await auth.signInAnonymously();
    setState(() {
      _signingInProgress = false;
    });
  }

  @override
  void initState() {
    super.initState();
    auth.currentUser().then((FirebaseUser user) {
      if (user == null) {
        if (shouldOfferLogin()) {
          Navigator.pushNamed(context, '/sign_in');
        } else {
          auth.signInAnonymously().then((FirebaseUser user) {
            print('Signed in anonymously');
          });
        }
      }
      setState(() {});
    });
  }

  bool shouldOfferLogin() {
    return true;
  }
}
