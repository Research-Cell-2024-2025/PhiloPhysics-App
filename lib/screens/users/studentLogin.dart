import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/screens/users/studentRegistration.dart';
import 'package:ephysicsapp/services/authentication.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();
  TextEditingController studentemailController = TextEditingController();
  TextEditingController studentpasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // State to manage loading


  // Function to reset password
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent. Please check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $e')),
      );
    }
  }

  checkValidation() {
    if (_formKeyValue.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading state to true
      });

      studentLogin(studentemailController.text, studentpasswordController.text, context).then((_) {
        setState(() {
          _isLoading = false; // Set loading state to false
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false; // Set loading state to false
        });
        // Handle login error (e.g., show error message)
        showToast("Login failed: $error");
      });
    }
  }

  void _showLoadingIndicator() {
    print('Loading start');
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(backgroundColor: Colors.transparent),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(
          key: _formKeyValue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height / 30),
              Text(
                "Student Login",
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: color5,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: studentemailController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter Email";
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Enter Email",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: studentpasswordController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter Password";
                  return null;
                },
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration( suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Use min to avoid extra width
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility ,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                          });
                        },
                      ),
                    ],
                  ),
                ),
                  labelText: "Enter Password",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  backgroundColor: color5,
                ),
                onPressed: _isLoading ? null : () { // Disable button if loading
                  checkValidation();
                },
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(color1), // Use your desired color
                )
                    : Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: color1),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 100),

              // Forgot Password Button
              TextButton(
                onPressed: () {
                  if (studentemailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter your email first.')),
                    );
                  } else {
                    resetPassword(studentemailController.text);
                  }
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: color5, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentRegister()),  // Replace with your registration page
                      );
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(color: color5, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
