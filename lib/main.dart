import 'package:ephysicsapp/screens/users/home.dart';
import 'package:ephysicsapp/services/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals/colors.dart'; // Assuming colors are defined in this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializePreferences();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Philo Physics',
      theme: ThemeData(
        primarySwatch: createMaterialColor(color5), // Custom primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(), // Initial screen of the app
    );
  }
}
