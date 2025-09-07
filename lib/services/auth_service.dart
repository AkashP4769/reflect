import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:reflect/services/user_service.dart';

class AuthService{
  static Future<Map<String, dynamic>> signInWithGoogle() async {
      // print("inside signInWithGoogle function");
      // final GoogleSignInAccount? gUser = await GoogleSignIn(
      //   scopes: <String>["email"],
      //   clientId: kIsWeb ? '176638636870-36pvnorj0aujq2ffgcqpoca5betf5fv8.apps.googleusercontent.com' : null,
      // ).signIn();

      // final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      // final credentials = GoogleAuthProvider.credential(
      //   accessToken: gAuth.accessToken,
      //   idToken: gAuth.idToken,
      // );

      // UserCredential? userCredential = await FirebaseAuth.instance.signInWithCredential(credentials);
      // print("signed in on google");
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
        print("Running on Windows");
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


      final authResponse = await UserService().addUser(userCredential!.user!.uid, userCredential.user!.displayName ?? '', userCredential.user!.email ?? '',);
      return authResponse;
      //return {"code": 0, "message": "Success"};
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