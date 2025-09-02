import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:reflect/services/user_service.dart';

class AuthService{
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try{
      print("inside signInWithGoogle function");
      final GoogleSignInAccount? gUser = await GoogleSignIn(
        scopes: <String>["email"],
        clientId: kIsWeb ? '176638636870-36pvnorj0aujq2ffgcqpoca5betf5fv8.apps.googleusercontent.com' : null,
      ).signIn();

      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credentials = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      /*UserCredential? userCredential;

      if(kIsWeb){
        userCredential = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());

      } else {
        // For mobile, we can directly use the credentials
        await FirebaseAuth.instance.signInWithCredential(credentials);
      }*/
      UserCredential? userCredential = await FirebaseAuth.instance.signInWithCredential(credentials);
      print("signed in on google");

      final authResponse = await UserService().addUser(userCredential!.user!.uid, userCredential.user!.displayName ?? '', userCredential.user!.email ?? '',);
      return authResponse;
      //return {"code": 0, "message": "Success"};
    }
    catch(e){
      print("Error at signInWithGoogle(): $e");
      return {"code": -1, "message": "Error: ${e.toString()}"};
    }
  }

  static Future<String> signInWithEmailPassword(String email, String password) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return '';
    }
    on FirebaseAuthException catch(e) {
      print("Error at signInWithEmailPassword(): $e");
      if(e.code == 'user-not-found') return "User not found";
      else if(e.code == 'wrong-password') return "Wrong password";
      return "Error: " + e.code;
    }
  }

  static Future<String> createUserWithEmailAndPassword(String name, String email, String password/* String phonenumber*/) async {
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      
      User? user = userCredential.user;
      print("User email verified: ");
      print(!user!.emailVerified);
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      /*//add user to firestore
      if(userCredential.user != null){
        await UserService.addUser(userCredential.user!.uid, name, email, phonenumber);
      }*/

      return '';
    }
    on FirebaseAuthException catch(e){
      print("Error at creatingUser(): ${e}");
      if(e.code == 'email-already-in-use') return "Email already in use, Please use a different email";
      else if(e.code == 'invalid-email') return "Invalid email";
      else if(e.code == 'weak-password') return "Weak password";
      return "Error: " + e.code;
    }
  }

  static Future<String> signOut() async {
    try{
      //await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
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