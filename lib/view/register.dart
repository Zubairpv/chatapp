import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controller/authsevice.dart';
import '../controller/shared_preference.dart';
import 'home.dart';
import 'login.dart';
import 'widgets.dart';

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
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: Form(
              key: formkey,
              child: Column(
                children: [
                  const Text(
                    'Groupie',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Create your account now to chat and explore',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Image.asset("assets/register.png"),
                  TextFormField(
                    decoration: textinputdecoration.copyWith(
                        labelText: 'Full name',
                        prefixIcon: const Icon(
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
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: textinputdecoration.copyWith(
                        labelText: 'Email',
                        prefixIcon: const Icon(
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
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: textinputdecoration.copyWith(
                        labelText: 'Password',
                        prefixIcon: const Icon(
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
                  const SizedBox(
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
                            backgroundColor: Theme.of(context).primaryColor),
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(
                      text: "Already have an account?",
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                            text: 'login here',
                            style: const TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                nextscreen(context, const Login());
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
          nextscreenreplace(context, const MyHomePage());
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
