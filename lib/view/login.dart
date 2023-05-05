import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controller/authsevice.dart';
import '../controller/shared preference.dart';
import 'home.dart';
import 'register.dart';
import 'widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  AuthService authService = AuthService();
  final formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
          child: Form(
              key: formkey,
              child: Column(
                children: [
                  Text(
                    'Groupie',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Login now to see what they are talking!',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Image.asset("assets/login.png"),
                  TextFormField(
                    decoration: textinputdecoration.copyWith(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).primaryColor,
                        )),
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!)
                          ? null
                          : 'Enter valid Email';
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: textinputdecoration.copyWith(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).primaryColor,
                        )),
                    validator: (value) {
                      if (value!.length < 6) {
                        return 'password must be at least 6 characters';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          logedin();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                            primary: Theme.of(context).primaryColor),
                        child: Text(
                          'Sign in',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(
                      text: "don't have an account?",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                            text: 'Register here',
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                nextscreen(context, const Register());
                              })
                      ]))
                ],
              )),
        ),
      ),
    );
  }

  logedin() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService.loginuser(email, password).then((value) async {
        if (value == true) {
          Shared.saveemail(email);
          Shared.saveloggedin(true);
          nextscreenreplace(context, MyHomePage());
        } else {
          showsnackbar(context, Colors.red, value);
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }
}
