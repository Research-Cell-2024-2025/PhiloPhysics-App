import 'package:ephysicsapp/main.dart';
import 'package:ephysicsapp/screens/users/home.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

late SharedPreferences prefs;

Future<void> initializePreferences() async {
  prefs = await SharedPreferences.getInstance();
}

// Admin login method
login(String email, String password, BuildContext context) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;

    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).catchError((e) {
      showToast(e.toString());
    });

    if (result != null) {
      prefs.setBool("isLogged", true);  // Mark as admin logged in
      Fluttertoast.showToast(msg: "Logged In as: $email", timeInSecForIosWeb: 4);

      // Use Navigator.pushAndRemoveUntil to remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
            (Route<dynamic> route) => false, // Remove all previous routes
      );
    }
  } catch (e) {
    // Handle the error here
  }
}


// Student registration method
Studentregister(String email, String name, String classdiv, String password,String collegeName, BuildContext context) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;

    // Create user in Firebase Authentication
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check if the user was successfully created
    if (result != null) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref();

      // Add user details to the Realtime Database under the "Users" node
      await dbRef.child('Users').child(result.user!.uid).set({
        'name': name,
        'classDiv': classdiv,
        'college': collegeName,
        'email': email,
        'role': 'Student',
      });

      // Show a success message
      showToast("User Registered Successfully");
      Navigator.pop(context);
    }
  } catch (e) {
    // Handle registration errors
    showToast(e.toString());
  }
}

// Student login method
Future<void> studentLogin(String email, String password, BuildContext context) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;

    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).catchError((e) {
      showToast(e.toString());
    });

    if (result != null) {
      String userId = result.user!.uid;
      DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = (await dbRef.child('Users').child(userId).once()).snapshot;

      if (snapshot.exists) {
        // Student found in Realtime Database
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        String role = userData['role'];

        if (role == 'Student') {
          // Store student UUID and set logged in state
          prefs.setString('studentUUID', userId); // Store student UUID
          prefs.setBool('isStudentLoggedIn', true); // Mark as student logged in

          showToast("Logged In as Student: $email");
          print("Logged In as Student: $email");
          print("Islogged first time usage track run:");
          final myAppState = context.findAncestorStateOfType<MyAppState>();
          if (myAppState != null) {
            myAppState.onUserLogin(userId); // Call onUserLogin when user logs in
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
                (Route<dynamic> route) => false, // Remove all previous routes
          );
        } else {
          showToast("You are not authorized to log in as a student.");
        }
      } else {
        showToast("No student found with this account.");
      }
    }
  } catch (e) {
    //showToast(e.toString());
    print(e.toString());
  }
}

// Logout method
Future<void> onLogout(BuildContext context) async {
  final myAppState = context.findAncestorStateOfType<MyAppState>();
  if (myAppState != null) {
    await myAppState.onUserLogout(); // End session and stop tracking
  }

  // Proceed with Firebase sign out
  await FirebaseAuth.instance.signOut();

  // Reset login preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("isLogged", false); // For admin
  prefs.setBool("isStudentLoggedIn", false); // For student
  prefs.remove("studentUUID");

  showToast("Logout Successful");

  // Navigate to the login screen
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return MyApp();
      },
    ),
        (Route route) => false,
  );
}


// Method to check if the user is logged in as admin
bool isLoggedIn() {
  return (prefs.getBool('isLogged') ?? false);
}

// Method to check if the student is logged in
bool isStudentLoggedIn() {
  return (prefs.getBool('isStudentLoggedIn') ?? false);
}
