import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gomoku/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              onPressed: () => signInWithGoogle(context),
              child: new Text("Sign in with Google"),
            ),
            new FlatButton(
              onPressed: () => proceedAnonymously(context),
              child: new Text("Don't sign in"),
            ),
          ],
        ),
      ),
    );
  }

  Future proceedAnonymously(BuildContext context) async {
    if (await auth.currentUser() == null) {
      await auth.signInAnonymously();
    }
    print('Signed in anonymously');
    proceed(context);
  }

  Future signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      await googleSignIn.signIn();
    }

    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials = await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(idToken: credentials.idToken, accessToken: credentials.accessToken);
    }

    print('Signed in: ${await auth.currentUser()}');
    proceed(context);
  }

  void proceed(BuildContext context) {
    Navigator.of(context).pop(auth.currentUser());
  }
}
