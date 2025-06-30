import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthManager {
  static Future<(bool, UserCredential?)> useEmailLogin() async {
    bool success = true;

    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: "email", password: "password")
        .catchError((e) {
          success = false;
        });

    if (success) {
      return Future.value((true, userCredential));
    }

    return Future.value((false, null));
  }

  static Future<(bool, UserCredential?)> useGoogleSignIn() async {
    UserCredential? cred;

    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope("email");
      cred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else if (Platform.isWindows) {
      OAuthCredential? oAuthCred = await _loginWindowsDesktop();
      if (oAuthCred != null) {
        cred = await FirebaseAuth.instance.signInWithCredential(oAuthCred);
      }
    }

    return Future.value((false, cred));
  }

  static void _lauchAuthInBrowser(String url) async {
    print(url);
    await canLaunchUrl(Uri.parse(url))
        ? await launchUrl(Uri.parse(url))
        : throw 'Could not lauch $url';
  }

  static Future<OAuthCredential?> _loginWindowsDesktop() async {
    var id = ClientId(
      Platform.environment["GOOGLE_CLIENT_ID"]!,
      Platform.environment["GOOGLE_CLIENT_SECRET"]!,
    );
    var scopes = ['email'];

    OAuthCredential? credential;

    var client = Client();
    await obtainAccessCredentialsViaUserConsent(
      id,
      scopes,
      client,
      (url) => _lauchAuthInBrowser(url),
    ).then((AccessCredentials credentials) {
      client.close();

      credential = GoogleAuthProvider.credential(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken.data,
      );
    });
    return Future.value(credential);
  }
}
