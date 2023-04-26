import 'package:shared_preferences/shared_preferences.dart';

class Shared {
  static String ukey = 'ukey';
  static String uname = 'uname';
  static String uemail = 'uemail';
  static String urll = 'urll';
  //set sf
  static Future<bool?> saveloggedin(bool islogedin) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(ukey, islogedin);
  }

  static Future<bool?> saveprofile(String url) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(urll, url);
  }

  static Future<bool?> savename(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(uname, userName);
  }

  static Future<bool?> saveemail(String email) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(uemail, email);
  }

//get sf
  static Future<bool?> getloggedin() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(ukey);
  }

  static Future<String?> getname() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(uname);
  }

  static Future<String?> getemail() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(uemail);
  }

  static Future<String?> getimage() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(urll);
  }

}