import 'package:ephysicsapp/main.dart';
import 'package:ephysicsapp/screens/users/home.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

late SharedPreferences prefs;
GoogleSignIn _googleSignIn = GoogleSignIn();

Future<void> initializePreferences() async {
  prefs = await SharedPreferences.getInstance();
}

// Admin login method
Future<void> login(String email, String password, BuildContext context) async {
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
Future<void> Studentregister(
    String email,
    String name,
    String classdiv,
    String password,
    String collegeName,
    BuildContext context,
    ) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();

    // Create user in Firebase Authentication with email/password
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check if the user was successfully created
    if (result != null) {
      // Authenticate Google sign-in
      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();

      if (googleUser == null) {
        // If no silent sign-in is possible, try to use GoogleSignIn with the credentials
        googleUser = await googleSignIn.signIn();
      }

      if (googleUser != null) {
        // Check if the Google account email matches the provided email
        if (googleUser.email.toLowerCase() != email.toLowerCase()) {
          // Emails do not match, stop registration
          Fluttertoast.showToast(
            msg: "The Google account email does not match the provided email.",
            timeInSecForIosWeb: 4,
          );
          // Delete the Firebase account created with email/password
          await result.user!.delete();
          await _auth.signOut();
          return;
        }

        // If emails match, proceed with linking the Google account
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        OAuthCredential googleCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Link Google account with the Firebase Authentication user
        await result.user!.linkWithCredential(googleCredential);
        print("Account linked with Google successfully");
      }

      // Add user details to the Realtime Database under the "Users" node
      DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      await dbRef.child('Users').child(result.user!.uid).set({
        'name': name,
        'classDiv': classdiv,
        'college': collegeName,
        'email': email,
        'role': 'Student',
      });

      // Show a success message
      Fluttertoast.showToast(
        msg: "User Account Created Successfully",
        timeInSecForIosWeb: 4,
      );
      Navigator.pop(context);
    }
  } catch (e) {
    // Handle registration errors
    print(e.toString());
    Fluttertoast.showToast(
      msg: "Error in registration: ${e.toString()}",
      timeInSecForIosWeb: 4,
    );
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
  try {
    final myAppState = context.findAncestorStateOfType<MyAppState>();
    if (myAppState != null) {
      await myAppState.onUserLogout(); // End session and stop tracking
    }

    // Proceed with Firebase sign out
    await FirebaseAuth.instance.signOut();

    // Ensure Google Sign-In is initialized
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Reset login preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all preferences instead of removing specific keys

    showToast("Logout Successful");

    // Navigate to the login screen and clear all routes
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return MyApp();
          },
        ),
            (Route route) => false,
      );
    }
  } catch (e) {
    print("Error during logout: $e");
    showToast("Logout Failed. Please try again.");
  }
}



// Method to check if the user is logged in as admin
bool isLoggedIn() {
  return (prefs.getBool('isLogged') ?? false);
}

// Method to check if the student is logged in
bool isStudentLoggedIn() {
  return (prefs.getBool('isStudentLoggedIn') ?? false);
}



// Google Logins
Future<void> studentLoginWithGoogle(BuildContext context) async {
  try {
    print("Google student login begins");

    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();

    // Attempt to sign in using Google account
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential from the Google account
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

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

            showToast("Logged In as Student: ${result.user!.email}");
            print("Logged In as Student: ${result.user!.email}");

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
            print("You are not authorized to log in as a student.");
            await googleSignIn.disconnect(); // Log out and clear Google account cache
            await _auth.signOut(); // Log out from Firebase
          }
        } else {
          Fluttertoast.showToast(msg: "No Account Found for this Google account.", timeInSecForIosWeb: 4);
          print('No account found.');
          await googleSignIn.disconnect(); // Clear Google account cache
          await _auth.signOut(); // Log out from Firebase
        }
      }
    }
  } catch (e) {
    print("Error in studentLoginWithGoogle: ${e.toString()}");
    Fluttertoast.showToast(msg: "You are not authorized to log in as a student.", timeInSecForIosWeb: 4);

    // Clear the cached Google account info to allow re-selection
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();
  }
}


Future<void> AdminloginWithGoogle(BuildContext context) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();

    // Attempt to sign in using Google account
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential from the Google account
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

      if (result != null) {
        print("User Exists");
        String role = '';
        String userId = result.user!.uid;
        DatabaseReference dbRef = FirebaseDatabase.instance.ref();

        // Fetch user data from 'Users' document
        DataSnapshot snapshot = (await dbRef.child('Users').child(userId).once()).snapshot;

        if (snapshot.exists) {
          Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
          role = userData['role'] ?? '';
        }

        // Check if the role is not 'Student' or user data does not exist
        if (role != 'Student' || !snapshot.exists) {
          prefs.setBool("isLogged", true); // Mark as admin logged in
          Fluttertoast.showToast(
            msg: "Logged In as Admin: ${result.user!.email}",
            fontSize: 14,
            timeInSecForIosWeb: 4,
            toastLength: Toast.LENGTH_LONG,
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
                (Route<dynamic> route) => false,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Cannot log in as Admin. User is a Student.",
            fontSize: 14,
            timeInSecForIosWeb: 4,
            toastLength: Toast.LENGTH_LONG,
          );
          await googleSignIn.disconnect(); // Clear Google account cache
          await _auth.signOut();
        }
      }
    }
  } catch (e) {
    print('Error: $e');
    Fluttertoast.showToast(msg: "Google login failed. Please try again.", timeInSecForIosWeb: 4);

    // Clear the cached Google account info to allow re-selection
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();
  }
}
