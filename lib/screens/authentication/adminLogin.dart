import 'package:ephysicsapp/globals/labels.dart';
import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/screens/users/studentLogin.dart';
import 'package:ephysicsapp/services/authentication.dart';
import 'package:ephysicsapp/widgets/generalWidgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

class AdminLogin extends StatefulWidget {
  AdminLogin({Key? key}) : super(key: key);

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  int _currentSelection = 0; // Default to 0 for StudentLogRegister

  Map<int, Widget> _children = {
    0: Text('Student'),
    1: Text('Admin'),
  };

  // Widget to display the current form
  Widget _currentWidget = StudentLogin();

  // Function to switch between Student and Admin forms
  void _switchPage(int index) {
    setState(() {
      _currentSelection = index;
      if (index == 0) {
        _currentWidget = StudentLogin(); // Show student login/register page
      } else if (index == 1) {
        _currentWidget = AdminLoginForm(); // Show admin login form
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: themeAppBar("Login"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 40,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: MaterialSegmentedControl(
                  children: _children,
                  selectionIndex: _currentSelection,
                  borderColor: Colors.black,
                  selectedColor: color5,
                  unselectedColor: Colors.white,
                  selectedTextStyle: TextStyle(
                      color: color1, fontWeight: FontWeight.bold, fontSize: 16),
                  unselectedTextStyle: TextStyle(
                      color: color5, fontWeight: FontWeight.bold, fontSize: 16),
                  borderWidth: 2,
                  borderRadius: 32.0,
                  onSegmentTapped: (index) {
                    _switchPage(
                        index as int); // Call the function to switch form
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 40,
              ),
              _currentWidget, // Display the current form based on selection
            ],
          ),
        ),
      ),
    );
  }
}

class AdminLoginForm extends StatefulWidget {
  const AdminLoginForm({super.key});

  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool isLoading = false;

  checkValidation() async {
    if (_formKeyValue.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await login(emailController.text, passwordController.text, context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed! Please Try Again')),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: _formKeyValue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 30,
            ),
            Text(
              loginPage,
              style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: color5),
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: emailController,
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
              controller: passwordController,
              validator: (value) {
                if (value!.isEmpty) return "Enter Password";
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Enter Password",
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Use min to avoid extra width
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible =
                                !_isPasswordVisible; // Toggle visibility
                          });
                        },
                      ),
                    ],
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 30),
            isLoading == true
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
          ],
        ),
      ),
    );
  }
}
