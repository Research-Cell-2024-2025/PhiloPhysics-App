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
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Attempt to sign in with email and password
    final UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      print("User Exists");
      final String userId = result.user!.uid;
      final DatabaseReference dbRef =
          FirebaseDatabase.instance.ref().child('Users').child(userId);

      // Fetch user data from 'Users' node
      final DataSnapshot snapshot = await dbRef.get();

      // Check if snapshot exists and extract the role
      if (snapshot.exists) {
        final Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;
        final String role = userData['role'] ?? '';

        // If role is not 'Student', log in as admin
        if (role != 'Student') {
          await prefs.setBool("isLogged", true);
          Fluttertoast.showToast(
            msg: "Logged In as: $email",
            fontSize: 14,
            timeInSecForIosWeb: 4,
            toastLength: Toast.LENGTH_LONG,
          );

          // Navigate to the home page and clear all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            (Route<dynamic> route) => false,
          );
        } else {
          // User is a student; show toast and sign out
          Fluttertoast.showToast(
            msg: "Cannot log in as Admin. User is a Student.",
            fontSize: 14,
            timeInSecForIosWeb: 4,
            toastLength: Toast.LENGTH_LONG,
          );
          await _auth.signOut();
        }
      } else {
        // No user data found in the database, treat as error
        Fluttertoast.showToast(
          msg: "User data not found.",
          fontSize: 14,
          timeInSecForIosWeb: 4,
          toastLength: Toast.LENGTH_LONG,
        );
        await _auth.signOut();
      }
    }
  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase authentication errors
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      Fluttertoast.showToast(msg: "Invalid Credentials", timeInSecForIosWeb: 4);
    } else {
      Fluttertoast.showToast(
          msg: "Login Failed: ${e.message}", timeInSecForIosWeb: 4);
    }
  } catch (e) {
    // Handle any other errors
    print('Error: $e');
    Fluttertoast.showToast(
        msg: "An error occurred. Please try again.", timeInSecForIosWeb: 4);
  }
}

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

    // Start creating user with email and password
    final userCreation = _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Always prompt the user to choose a Google account
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Await user creation result
    final result = await userCreation;

    if (result != null) {
      // Save user details to the Realtime Database
      final dbRef = FirebaseDatabase.instance.ref();

      if (googleUser != null) {
        // Get Google authentication details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        OAuthCredential googleCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Check if the Google account email matches the provided email
        if (googleUser.email.toLowerCase() != email.toLowerCase()) {
          Fluttertoast.showToast(
            msg: "The Google account email does not match the provided email.",
            timeInSecForIosWeb: 4,
          );

          // Disconnect the Google account to force the account selection prompt next time
          await googleSignIn.disconnect();
          await googleSignIn.signOut();

          // Delete the Firebase account created with email/password
          await result.user!.delete();
          await _auth.signOut();
          Navigator.pop(context);
          return;
        }

        // Link Google account with the Firebase Authentication user
        await result.user!.linkWithCredential(googleCredential);
        print("Account linked with Google successfully");

        // Show a success message for Google linking
        Fluttertoast.showToast(
          msg: "User Account Created and Linked with Google Successfully",
          timeInSecForIosWeb: 4,
        );
      } else {
        // Show a success message for email/password registration only
        Fluttertoast.showToast(
          msg: "User Account Created Successfully",
          timeInSecForIosWeb: 4,
        );
      }

      // Save user details to the Realtime Database
      await dbRef.child('Users').child(result.user!.uid).set({
        'name': name,
        'classDiv': classdiv,
        'college': collegeName,
        'email': email,
        'role': 'Student',
      });

      // Navigate back to the previous screen
      Navigator.pop(context);
    }
  } catch (e) {
    // Handle registration errors
    print(e.toString());
    Fluttertoast.showToast(
      msg: "Error in registration: ${e.toString()}",
      timeInSecForIosWeb: 4,
    );

    // Ensure user is fully signed out on error to prevent cached accounts
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
  }
}

// Optimized Student login method
Future<void> studentLogin(
    String email, String password, BuildContext context) async {
  try {
    print("Student login begins");
    FirebaseAuth _auth = FirebaseAuth.instance;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    // Start Firebase Authentication login
    final signInFuture =
        _auth.signInWithEmailAndPassword(email: email, password: password);

    // Execute sign-in and get user data concurrently
    UserCredential result = await signInFuture.catchError((e) {
      print("Firebase Auth Error: ${e.toString()}");
      Fluttertoast.showToast(
        msg: "Invalid Credentials",
        timeInSecForIosWeb: 4,
      );
      throw e;
    });

    // Check if user login was successful
    if (result.user == null) return;

    String userId = result.user!.uid;

    // Fetch user data from Firebase Database in parallel
    final snapshot = await dbRef.child('Users/$userId').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
      String role = userData['role'] ?? '';

      if (role == 'Student') {
        print('Role is Student');
        await prefs.setString('studentUUID', userId);
        await prefs.setBool('isStudentLoggedIn', true);

        showToast("Logged In as Student: $email");
        print("Logged In as Student: $email");

        // Navigate to the home page and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
        );

        // Notify MyAppState of user login
        final myAppState = context.findAncestorStateOfType<MyAppState>();
        myAppState?.onUserLogin(userId);
      } else {
        showToast("You are not authorized to log in as a student.");
        await _auth.signOut();
      }
    } else {
      // User not found in Realtime Database
      print("User not found in Firebase Database");
      Fluttertoast.showToast(
        msg: "You are not authorized to log in as a student.",
        timeInSecForIosWeb: 4,
      );
      await _auth.signOut();
    }
  } catch (e) {
    print("Error in studentLogin: ${e.toString()}");
    Fluttertoast.showToast(
      msg: "Incorrect Credentials! / No Account Found",
      timeInSecForIosWeb: 4,
    );
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
    await prefs
        .clear(); // Clear all preferences instead of removing specific keys

    showToast("Logout Successful");

    // Navigate to the login screen and clear all routes
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
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

// Optimized Google Student Login Method
Future<void> studentLoginWithGoogle(BuildContext context) async {
  try {
    print("Google student login begins");

    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();

    // Attempt to sign in using Google account
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      Fluttertoast.showToast(
          msg: "Google sign-in cancelled", timeInSecForIosWeb: 4);
      return;
    }

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create Google credential
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with the Google credential
    UserCredential result = await _auth.signInWithCredential(credential);
    if (result.user == null) {
      Fluttertoast.showToast(
          msg: "Firebase sign-in failed", timeInSecForIosWeb: 4);
      return;
    }

    String userId = result.user!.uid;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    // Fetch user data from Firebase Database
    DataSnapshot snapshot = await dbRef.child('Users/$userId').get();

    if (!snapshot.exists) {
      print("No account found in the database.");
      Fluttertoast.showToast(
          msg: "No Account Found for this Google account.",
          timeInSecForIosWeb: 4);
      await googleSignIn.disconnect(); // Clear Google account cache
      await _auth.signOut();
      return;
    }

    // Extract user data
    Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
    String role = userData['role'] ?? '';

    // Check if the user has the 'Student' role
    if (role == 'Student') {
      print('Role is Student');
      await prefs.setString('studentUUID', userId); // Cache student UUID
      await prefs.setBool(
          'isStudentLoggedIn', true); // Mark as student logged in

      showToast("Logged In as Student: ${result.user!.email}");
      print("Logged In as Student: ${result.user!.email}");

      // Navigate to the home page and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false,
      );

      // Notify MyAppState of user login
      final myAppState = context.findAncestorStateOfType<MyAppState>();
      myAppState?.onUserLogin(userId);
    } else {
      showToast("You are not authorized to log in as a student.");
      print("You are not authorized to log in as a student.");
      await googleSignIn.disconnect(); // Clear Google account cache
      await _auth.signOut();
    }
  } catch (e) {
    print("Error in studentLoginWithGoogle: ${e.toString()}");
    Fluttertoast.showToast(
        msg: "Login failed: ${e.toString()}", timeInSecForIosWeb: 4);

    // Clear cached Google account to allow re-selection
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}

// Optimized Admin Google Login Method
Future<void> adminLoginWithGoogle(BuildContext context) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();

    // Attempt to sign in using Google account
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      Fluttertoast.showToast(
          msg: "Google sign-in cancelled", timeInSecForIosWeb: 4);
      return;
    }

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create Google credential
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with the Google credential
    UserCredential result = await _auth.signInWithCredential(credential);
    if (result.user == null) {
      Fluttertoast.showToast(
          msg: "Firebase sign-in failed", timeInSecForIosWeb: 4);
      return;
    }

    print("User Exists");
    String userId = result.user!.uid;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    // Fetch user data from Firebase Database
    DataSnapshot snapshot = await dbRef.child('Users/$userId').get();

    // Check if the user data exists and is not a student
    if (snapshot.exists) {
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
      String role = userData['role'] ?? '';

      if (role != 'Student') {
        print("Logged In as Admin");
        prefs.setBool("isLogged", true); // Mark as admin logged in

        Fluttertoast.showToast(
          msg: "Logged In as Admin: ${result.user!.email}",
          fontSize: 14,
          timeInSecForIosWeb: 4,
          toastLength: Toast.LENGTH_LONG,
        );

        // Navigate to the admin home page and clear navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        print("Cannot log in as Admin. User is a Student.");
        Fluttertoast.showToast(
          msg: "Cannot log in as Admin. User is a Student.",
          fontSize: 14,
          timeInSecForIosWeb: 4,
          toastLength: Toast.LENGTH_LONG,
        );
        await googleSignIn.disconnect(); // Log out and clear Google cache
        await _auth.signOut();
      }
    } else {
      print("No account found in the database.");
      Fluttertoast.showToast(
        msg: "No Account Found for this Google account.",
        timeInSecForIosWeb: 4,
        toastLength: Toast.LENGTH_LONG,
      );
      await googleSignIn.disconnect(); // Clear Google cache
      await _auth.signOut();
    }
  } catch (e) {
    print("Error: $e");
    Fluttertoast.showToast(
      msg: "Google login failed. Please try again.",
      timeInSecForIosWeb: 4,
    );

    // Clear Google account info to allow re-selection on retry
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
