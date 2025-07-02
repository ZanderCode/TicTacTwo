import 'dart:convert';
import 'dart:io';
import 'dart:ui' as html;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:universal_html/html.dart' hide Platform, HttpRequest;
import 'package:window_manager/window_manager.dart';

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
      return await _loginWeb();
    } else if (Platform.isWindows) {
      return await _loginWindowsDesktop();
    }

    return Future.value((false, cred));
  }

  static Future<void> _lauchAuthInBrowser(String url) async {
    print(url);
    await canLaunchUrl(Uri.parse(url))
        ? await launchUrl(Uri.parse(url))
        : throw 'Could not lauch $url';
  }

  static Future<Map<String, String>> _getOAuthToken(
    String fromCode,
    int fromPort, {
    String additionalPath = "",
  }) async {
    final uri = Uri.parse(
      'http://127.0.0.1:5001/tictactwo-c1026/us-central1/getTokenData',
    );

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': fromCode,
        'redirectUri': 'http://localhost:$fromPort$additionalPath',
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {
        'firebaseToken': data['firebaseToken'],
        'googleIdToken': data['googleIdToken'],
        'googleAccessToken': data['googleAccessToken'],
      };
    } else {
      throw Exception('Function failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<(bool, UserCredential?)> _loginWindowsDesktop() async {
    UserCredential? cred;
    int port = await getFreePort();
    await launchGoogleLogin(port);
    String? code = await listenForCode(port);
    if (code != null) {
      Map<String, String> map = await _getOAuthToken(code, port);
      if (map["firebaseToken"] != null) {
        cred = await FirebaseAuth.instance.signInWithCustomToken(
          map["firebaseToken"] ?? "",
        );

        final googleIdToken = map['googleIdToken']!;
        final googleAccessToken = map['googleAccessToken']!;

        final googleCredential = GoogleAuthProvider.credential(
          idToken: googleIdToken,
          accessToken: googleAccessToken,
        );
        try {
          await FirebaseAuth.instance.currentUser?.linkWithCredential(
            googleCredential,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked') {
            print('The provider is already linked to the user.');
          } else if (e.code == 'credential-already-in-use') {
            print(
              'The account corresponding to the credential already exists.',
            );
            // You might want to sign in with credential instead in this case.
          } else {
            print('Error linking credential: $e');
          }
        }

        return Future.value((true, cred));
      }
    }

    return Future.value((false, cred));
  }

  static Future<(bool, UserCredential?)> _loginWeb() async {
    UserCredential? cred;
    await launchGoogleLogin(8080, additionalPath: "/oauth-redirect.html");

    String? code = await waitForAuthCode() ?? "";

    print("this is the code: " + code);

    Map<String, String> map = await _getOAuthToken(
      code,
      8080,
      additionalPath: "/oauth-redirect.html",
    );

    //removeAuthCode();

    if (map["firebaseToken"] != null) {
      cred = await FirebaseAuth.instance.signInWithCustomToken(
        map["firebaseToken"] ?? "",
      );

      final googleIdToken = map['googleIdToken']!;
      final googleAccessToken = map['googleAccessToken']!;

      final googleCredential = GoogleAuthProvider.credential(
        idToken: googleIdToken,
        accessToken: googleAccessToken,
      );
      try {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(
          googleCredential,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          print('The provider is already linked to the user.');
        } else if (e.code == 'credential-already-in-use') {
          print('The account corresponding to the credential already exists.');
          // You might want to sign in with credential instead in this case.
        } else {
          print('Error linking credential: $e');
        }
      }

      return Future.value((true, cred));
    }

    return Future.value((false, cred));
  }

  static Future<String?> waitForAuthCode({
    Duration timeout = const Duration(seconds: 60),
  }) async {
    const pollInterval = Duration(milliseconds: 500);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final code = getAuthCode();
      if (code != null) {
        removeAuthCode();
        return code;
      }
      await Future.delayed(pollInterval);
    }

    return null; // Timed out
  }

  static String? getAuthCode() => window.localStorage['auth_code'];
  static void removeAuthCode() => window.localStorage.remove('auth_code');

  static Future<String?> listenForCode(int port) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    print('Listening for OAuth redirect on http://localhost:$port');

    await for (HttpRequest request in server) {
      final uri = request.uri;
      if (uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code'];

        // Respond with something user-friendly so the browser tab doesn't hang
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write(
            '<html><body><h3>You can close this window now.</h3></body></html>',
          );
        await request.response.close();

        await server.close();
        return code;
      } else {
        // If no code param, respond 404 or redirect
        request.response
          ..statusCode = 404
          ..close();
      }
    }
    return null;
  }

  static Future<int> getFreePort() async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();
    return port;
  }

  static Future<void> launchGoogleLogin(
    int redirectPort, {
    String additionalPath = "",
  }) async {
    final clientId =
        '500852408753-v5dcit0cit5ptb2699ei1b0bi8f3jcvq.apps.googleusercontent.com';
    final redirectUri = 'http://localhost:$redirectPort$additionalPath';
    final scopes = 'email profile openid';

    final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes,
      'access_type': 'offline',
      'prompt': 'consent',
    }).toString();

    await _lauchAuthInBrowser(url);
  }
}
