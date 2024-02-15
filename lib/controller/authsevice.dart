
// ignore_for_file: unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';

import 'database_service.dart';
import 'shared_preference.dart';


class AuthService {
  String email = '';
  String fullname = '';
  String password = '';
  bool isLoading = false;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Future loginuser(String email, String password) async {
    try {
      User? user = (await firebaseAuth.signInWithEmailAndPassword(
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
      User? user = (await firebaseAuth.createUserWithEmailAndPassword(
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
