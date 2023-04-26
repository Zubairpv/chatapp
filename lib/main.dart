import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'controller/shared preference.dart';
import 'view/home.dart';
import 'view/login.dart';
import 'view/profile.dart';
import 'view/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool issignedin = false;
  @override
  void initState() {
    getuser();
    Shared.getimage().then((value) {
      print(value);
      setState(() {
        url = value;
      });
      print('url-$url');
    });
    super.initState();
  }

  getuser() async {
    Shared.getloggedin().then((value) {
      if (value != null) {
        setState(() {
          issignedin = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
            primaryColor: primarycolor, scaffoldBackgroundColor: Colors.white),
        home: issignedin ? const MyHomePage() : const Login());
  }
}
