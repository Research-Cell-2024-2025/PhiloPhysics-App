import 'package:ephysicsapp/globals/labels.dart';
import 'package:ephysicsapp/globals/colors.dart';
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
  int _currentSelection = 0;  // Default to 0 for StudentLogRegister

  Map<int, Widget> _children = {
    0: Text('Student'),
    1: Text('Admin'),
  };

  // Widget to display the current form
  Widget _currentWidget = StudentLogRegister();

  // Function to switch between Student and Admin forms
  void _switchPage(int index) {
    setState(() {
      _currentSelection = index;
      if (index == 0) {
        _currentWidget = StudentLogRegister(); // Show student login/register page
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
                  selectedTextStyle: TextStyle(color: color1, fontWeight: FontWeight.bold, fontSize: 16),
                  unselectedTextStyle: TextStyle(color: color5, fontWeight: FontWeight.bold, fontSize: 16),
                  borderWidth: 2,
                  borderRadius: 32.0,
                  onSegmentTapped: (index) {
                    _switchPage(index as int);  // Call the function to switch form
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 40,
              ),
              _currentWidget,  // Display the current form based on selection
            ],
          ),
        ),
      ),
    );
  }
}

class StudentLogRegister extends StatefulWidget {
  const StudentLogRegister({super.key});

  @override
  State<StudentLogRegister> createState() => _StudentLogRegisterState();
}

class _StudentLogRegisterState extends State<StudentLogRegister> {

  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();
  TextEditingController studentemailController = TextEditingController();
  TextEditingController studentpasswordController = TextEditingController();


  checkValidation()
  {
    if(_formKeyValue.currentState!.validate()){
      studentLogin(studentemailController.text,studentpasswordController.text,context);
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
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              Text(
                "Student Login",
                style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: color5),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
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
              SizedBox(
                height: MediaQuery.of(context).size.height / 100,
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
                        MaterialPageRoute(builder: (context) => StudentAccountCreation()),  // Replace with your registration page
                      );
                    },
                    child: Text(
                      'Create one',
                      style: TextStyle(color: color5, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );  // Replace with actual Student Login/Register form
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

  checkValidation() {
    if (_formKeyValue.currentState!.validate()) {
      login(emailController.text, passwordController.text, context);
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
              obscureText: true,
              decoration: InputDecoration(
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


class StudentAccountCreation extends StatefulWidget {
  const StudentAccountCreation({super.key});

  @override
  State<StudentAccountCreation> createState() => _StudentAccountCreationState();
}

class _StudentAccountCreationState extends State<StudentAccountCreation> {
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  TextEditingController studentAccCreationemailController = TextEditingController();
  TextEditingController studentAccCreationnameController = TextEditingController();
  TextEditingController studentAccCreationYearDivController = TextEditingController();
  TextEditingController studentAccCreationpasswordController = TextEditingController();
  TextEditingController otherCollegeNameController = TextEditingController();

  // Track the selected college radio button
  String _selectedCollege = 'Sakec';
  bool _isOtherCollegeSelected = false;

  checkValidation() {
    if (_formKeyValue.currentState!.validate()) {
      // Pass 'Sakec' if 'Sakec' is selected, or pass the controller value for 'Others'
      String collegeName = _selectedCollege == 'Sakec'
          ? 'Sakec'
          : otherCollegeNameController.text;

      // Call the registration method with the appropriate values
      Studentregister(
        studentAccCreationemailController.text,
        studentAccCreationnameController.text,
        studentAccCreationYearDivController.text,
        studentAccCreationpasswordController.text,
        collegeName,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Form(
        key: _formKeyValue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              Text(
                "Student Register",
                style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: color5),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: studentAccCreationnameController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter Name";
                  return null;
                },
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Enter Name",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Enter College: ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'Sakec',
                          groupValue: _selectedCollege,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedCollege = value!;
                              _isOtherCollegeSelected = false;
                            });
                          },
                        ),
                        Text('SAKEC', style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: color5),),
                        SizedBox(width: 10),
                        Radio<String>(
                          value: 'Others',
                          groupValue: _selectedCollege,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedCollege = value!;
                              _isOtherCollegeSelected = true;
                            });
                          },
                        ),
                        Text('OTHER', style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: color5),),
                      ],
                    ),
                  ),
                ],
              ),
              // If 'Others' is selected, display the text field for entering college name
              if (_isOtherCollegeSelected)
                Column(
                  children: [
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: otherCollegeNameController,
                      validator: (value) {
                        if (_isOtherCollegeSelected && value!.isEmpty) {
                          return "Enter College Name";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintMaxLines: 2,
                        labelText: "Enter College Name",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              TextFormField(
                controller: studentAccCreationemailController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter Email";
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Enter Email",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: studentAccCreationYearDivController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter Class-Div";
                  return null;
                },
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Enter Class-Div",
                  hintText: "Enter like Eg. FE-9",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: studentAccCreationpasswordController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter Password";
                  return null;
                },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Enter Password",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  backgroundColor: color5,
                ),
                onPressed: () {
                  checkValidation();
                },
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
