import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/screens/users/studentRegistration.dart';
import 'package:ephysicsapp/services/authentication.dart';
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
  bool isLoading = false;

  // Function to reset password
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Password reset email sent. Please check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $e')),
      );
    }
  }

  Future<void> checkValidation() async {
    if (_formKeyValue.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await studentLogin(
          studentemailController.text,
          studentpasswordController.text,
          context,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Enter Password",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 30),

              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        backgroundColor: color5,
                      ),
                      onPressed: () {
                        checkValidation();
                      },
                      child: Text(
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
                  style: TextStyle(
                      color: color5, fontSize: 16, fontWeight: FontWeight.bold),
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
                        MaterialPageRoute(
                            builder: (context) =>
                                StudentRegister()), // Replace with your registration page
                      );
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                          color: color5,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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
