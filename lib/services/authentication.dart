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

    // Attempt to sign in with email and password
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).catchError((e) {
      Fluttertoast.showToast(msg: "Invalid Credentials", timeInSecForIosWeb: 4);
    });

    if (result != null) {
      print("User Exists");
      String role = '';
      String userId = result.user!.uid;
      DatabaseReference dbRef = FirebaseDatabase.instance.ref();

      // Fetch user data from 'Users' document
      DataSnapshot snapshot = (await dbRef.child('Users').child(userId).once()).snapshot;

      if (snapshot.exists) {
        // Get user role if the user exists
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        role = userData['role'] ?? '';
      }

      // Check if the role is not 'Student' or user data does not exist
      if (role != 'Student' || !snapshot.exists) {
        // Log in as an admin
        prefs.setBool("isLogged", true);  // Mark as admin logged in
        Fluttertoast.showToast(
          msg: "Logged In as: $email",
          fontSize: 14,
          timeInSecForIosWeb: 4,
          toastLength: Toast.LENGTH_LONG,
        );

        // Navigate to the home page and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
              (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else {
        // Show toast if the user is a 'Student'
        Fluttertoast.showToast(
          msg: "Cannot log in as Admin. User is a Student.",
          fontSize: 14,
          timeInSecForIosWeb: 4,
          toastLength: Toast.LENGTH_LONG,
        );

        // Sign out the user
        await _auth.signOut();
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}



// Student registration method
Future<void> Studentregister(String email, String name, String classdiv, String password,String collegeName, BuildContext context) async {
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
      Fluttertoast.showToast(msg: "User Account Created Successfully",timeInSecForIosWeb: 4);
      Navigator.pop(context);
    }
  } catch (e) {
    // Handle registration errors
    print(e.toString());
  }
}

// Student login method
Future<void> studentLogin(String email, String password, BuildContext context) async {
  try {
    print("student login begins");
    FirebaseAuth _auth = FirebaseAuth.instance;

    // Attempt to log in with email and password
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).catchError((e) {
      print("Firebase Auth Error: ${e.toString()}"); // Log Firebase Auth errors
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
          print('Role is Student');
          prefs.setString('studentUUID', userId); // Store student UUID
          prefs.setBool('isStudentLoggedIn', true); // Mark as student logged in

          showToast("Logged In as Student: $email");
          print("Logged In as Student: $email");

          // Navigate to the home page and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false, // Remove all previous routes
          );

          final myAppState = context.findAncestorStateOfType<MyAppState>();
          if (myAppState != null) {
            myAppState.onUserLogin(userId); // Call onUserLogin when user logs in
          }


        } else {
          showToast("You are not authorized to log in as a student.");
        }
      } else {
        print("Not Student");
        Fluttertoast.showToast(msg :"You are not authorized to log in as a student.");
      }
    }
  } catch (e) {
    print("Error in studentLogin: ${e.toString()}");
    Fluttertoast.showToast(msg: "Incorrect Credentials ! / No Account Found",timeInSecForIosWeb: 4);
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
