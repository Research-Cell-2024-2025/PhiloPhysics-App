import 'package:ephysicsapp/main.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

Future<void> initializePreferences() async {
  prefs = await SharedPreferences.getInstance();
}

login(String email,String password,BuildContext context) async{

    FirebaseAuth _auth = FirebaseAuth.instance;
    UserCredential result = await _auth
                  .signInWithEmailAndPassword(
                      email: email, password: password)
                  .catchError((e) {
                showToast(e.toString());
              });

    if(result!=null)
    {
        prefs.setBool("isLoggedIn", true);
        showToast("Logged In as: ${email}");
        Navigator.of(context).pop();
    }
}

onLogout(BuildContext context) async{
  await FirebaseAuth.instance.signOut();
  prefs.setBool("isLoggedIn", false);
  Navigator.pushAndRemoveUntil(context, PageRouteBuilder(
    pageBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation) {
      return MyApp();
    },
  ), (Route route) => false);
  showToast("Logout Successfull");
}

isLoggedIn()
{
  bool isLoggedIn;
  isLoggedIn = (prefs.getBool('isLoggedIn') ?? false);
  return isLoggedIn;
}