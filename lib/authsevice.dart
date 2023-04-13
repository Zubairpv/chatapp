import 'dart:math';

import 'package:chatt_app/database_service.dart';
import 'package:chatt_app/shared%20preference.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future loginuser(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (f) {
      return f.message;
    }
  }

  //register
  Future registeruser(String fullname, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        //database service
        await Databaseservice(user.uid).savingUserData(fullname, email);

        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future signout() async {
    try {
      Shared.saveloggedin(false);
      Shared.savename('');
      Shared.saveemail('');
    } catch (e) {
      return null;
    }
  }
}
