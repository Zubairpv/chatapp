import 'package:chatt_app/authsevice.dart';
import 'package:chatt_app/home.dart';
import 'package:chatt_app/login.dart';
import 'package:chatt_app/shared%20preference.dart';
import 'package:chatt_app/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formkey = GlobalKey<FormState>();
  String email = '';
  String fullname = '';
  String password = '';
  bool isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
                    'Create your account now to chat and explore',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Image.asset("assets/register.png"),
                  TextFormField(
                    decoration: textinputdecoration.copyWith(
                        labelText: 'Full name',
                        prefixIcon: Icon(
                          Icons.email,
                          color: primarycolor,
                        )),
                    onChanged: (value) {
                      setState(() {
                        fullname = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        return null;
                      } else {
                        return "Name can't be empty";
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: textinputdecoration.copyWith(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: primarycolor,
                        )),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
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
                          color: primarycolor,
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
                          signup();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                            primary: Theme.of(context).primaryColor),
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(
                      text: "Already have an account?",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                            text: 'login here',
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                nextscreen(context, Login());
                              })
                      ]))
                ],
              )),
        ),
      ),
    );
  }

  signup() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService
          .registeruser(fullname, email, password)
          .then((value) async {
        if (value == true) {
          Shared.savename(fullname);
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
