import 'package:flutter/material.dart';

const primarycolor = Color(0xFFee7b64);
const textinputdecoration = InputDecoration(
  
    labelStyle: TextStyle(color: primarycolor, fontWeight: FontWeight.w300),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primarycolor, width: 2)),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primarycolor, width: 2)),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primarycolor, width: 2)));
void nextscreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

nextscreenreplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showsnackbar(context, color, messsage) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      messsage,
      style: TextStyle(fontSize: 14),
    ),
    backgroundColor: color,
    duration: Duration(seconds: 2),
    action: SnackBarAction(
      label: 'ok',
      onPressed: () {},
      textColor: Colors.white,
    ),
  ));
}
