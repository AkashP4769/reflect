import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:reflect/services/user_service.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService{
  static Future<Map<String, dynamic>> signInWithGoogle() async {
      UserCredential? userCredential;

      if(kIsWeb){
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');

        if(defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
          await FirebaseAuth.instance.signInWithRedirect(googleProvider);
          userCredential = await FirebaseAuth.instance.getRedirectResult();
        }
        else userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      }

      else if (defaultTargetPlatform == TargetPlatform.windows) {
        userCredential = await signInWithGoogleWindows();
      }

      else {
        print("Not web platform");
        final _googleSignIn = GoogleSignIn.instance;
        await _googleSignIn.initialize();
  
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = googleUser!.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken,);

        // Once signed in, return the UserCredential
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if(userCredential == null ) {
        return {"code": -1, "message": "Error during Google Sign-In"};
      }

      final authResponse = await UserService().addUser(userCredential!.user!.uid, userCredential!.user!.displayName ?? '', userCredential!.user!.email ?? '',);
      return authResponse;
  }

  

  static Future<Map<String, dynamic>> signInWithEmailPassword(String email, String password) async {
    try{
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final authResponse = await UserService().addUser(userCredential!.user!.uid, email.split('@')[0], email);
      return authResponse;
    }
    on FirebaseAuthException catch(e) {
      print("Error at signInWithEmailPassword(): $e");
      if(e.code == 'user-not-found') return {"code": -1, "message": "User not found"};
      else if(e.code == 'wrong-password') return {"code": -1, "message": "Wrong password"};
      return {"code": -1, "message": "Error: ${e.code}"};
    }
  }

  static Future<Map<String, dynamic>> createUserWithEmailAndPassword(String name, String email, String password/* String phonenumber*/) async {
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      
      User? user = userCredential.user;
      print("User email verified: ");
      print(!user!.emailVerified);
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      final authResponse = await UserService().addUser(userCredential!.user!.uid, name, email);
      return authResponse;
    }
    on FirebaseAuthException catch(e){
      print("Error at creatingUser(): ${e}");
      if(e.code == 'email-already-in-use') return {"code": -1, "message": "Email already in use, Please use a different email"};
      else if(e.code == 'invalid-email') return {"code": -1, "message": "Invalid email"};
      else if(e.code == 'weak-password') return {"code": -1, "message": "Weak password"};
      return {"code": -1, "message": "Error: " + e.code};
    }
  }

  static Future<String> signOut() async {
    try{
      //await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      return '';

    } on FirebaseAuthException catch (e) {
      print("Error during signOut(): $e");
      return "Error: ${e.code}";

    } catch (e) {
      print("Unexpected error during signOut(): $e");
      return "An unexpected error occurred during sign out.";
    }
  }
}

// Generate random string for PKCE
String _randomString(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final rand = Random.secure();
  return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
}

// Base64 URL encode without padding
String _base64UrlEncode(List<int> bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

Future<UserCredential?> signInWithGoogleWindows() async {
  final clientId = dotenv.env['CLIENT_ID'] ?? 'null';
  final clientSecret = dotenv.env['CLIENT_SECRET'] ?? 'null';
  final redirectUri = 'http://127.0.0.1:6699/';
  final scopes = ['openid', 'email', 'profile'];

  //read from env file
  if (clientId == 'null' || clientSecret == 'null') {
    throw Exception("CLIENT_ID or CLIENT_SECRET not found in .env file");
  }

  // 1. Generate PKCE code verifier + challenge
  final codeVerifier = _randomString(128);
  final codeChallenge = _base64UrlEncode(sha256.convert(utf8.encode(codeVerifier)).bytes);

  // 2. Build authorization URL
  final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'response_type': 'code',
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'scope': scopes.join(' '),
    'code_challenge': codeChallenge,
    'code_challenge_method': 'S256',
    'access_type': 'offline'
  });

  // 3. Open browser
  if (Platform.isWindows) {
    //final url = authUrl.toString();
    print("Opening URL: ${authUrl.toString()}");
    //run the url using url_launcher
    if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${authUrl.toString()}');
    }

  } else {
    throw Exception("This helper is for Windows only.");
  }

  // 4. Start local HTTP server to catch redirect
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 6699);
  final request = await server.first;
  final queryParams = request.uri.queryParameters;
  final code = queryParams['code'];
  request.response
    ..statusCode = 200
    ..headers.set('Content-Type', 'text/html')
    ..write('<h2>You may now close this window.</h2>')
    ..close();
  await server.close(force: true);

  if (code == null) {
    throw Exception("No authorization code returned");
  }

  // 5. Exchange code for tokens
  final tokenResp = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'code': code,
      'client_id': clientId,
      'client_secret': clientSecret,
      'code_verifier': codeVerifier,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
    },
  );

  if (tokenResp.statusCode != 200) {
    throw Exception("Token exchange failed: ${tokenResp.body}");
  }

  final tokenJson = jsonDecode(tokenResp.body);
  final accessToken = tokenJson['access_token'];
  final idToken = tokenJson['id_token'];

  // 6. Sign in to Firebase
  final credential = GoogleAuthProvider.credential(
    idToken: idToken,
    accessToken: accessToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}