import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/services/authentication.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentRegister extends StatefulWidget {
  const StudentRegister({super.key});

  @override
  State<StudentRegister> createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  String password = '';
  String confirmPassword = '';

  bool hasUppercase = false;
  bool hasSpecialChar = false;
  bool hasNumber = false;
  bool hasMinLength = false;
  bool isPasswordMatching = false;

  FocusNode passwordFocusNode = FocusNode();
  bool isPasswordFieldFocused = false;

  bool isLoading = false;

  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  TextEditingController studentAccCreationemailController =
      TextEditingController();
  TextEditingController studentAccCreationnameController =
      TextEditingController();
  TextEditingController studentAccCreationYearDivController =
      TextEditingController();
  TextEditingController studentAccCreationpasswordController =
      TextEditingController();
  TextEditingController otherCollegeNameController = TextEditingController();

  // Track the selected college radio button
  String _selectedCollege = 'Sakec';
  bool _isOtherCollegeSelected = false;

  Future<void> checkValidation() async {
    if (!_formKeyValue.currentState!.validate()) {
      showToast("Please fill all the fields correctly");
      return;
    }

    if (!hasUppercase || !hasSpecialChar || !hasNumber || !hasMinLength) {
      showToast("Password does not meet all criteria");
      return;
    }

    if (!isPasswordMatching) {
      showToast("Passwords do not match");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String collegeName = _selectedCollege == 'Sakec'
          ? 'Sakec'
          : otherCollegeNameController.text;

      // Call the registration method with the appropriate values
      await Studentregister(
        studentAccCreationemailController.text,
        studentAccCreationnameController.text,
        studentAccCreationYearDivController.text,
        studentAccCreationpasswordController.text,
        collegeName,
        context,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() {
      setState(() {
        isPasswordFieldFocused = passwordFocusNode.hasFocus;
      });
    });
  }

  void checkPasswordStrength(String password) {
    setState(() {
      this.password = password;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
      hasMinLength = password.length >= 8 && password.length <= 20;
    });
  }

  void checkPasswordMatch(String confirmPassword) {
    setState(() {
      this.confirmPassword = confirmPassword;
      isPasswordMatching = password == confirmPassword;
    });
  }

  Widget buildPasswordCriteriaIcon(bool criteria) {
    return Icon(
      criteria ? Icons.check_circle : Icons.cancel,
      color: criteria ? Colors.green : Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create An Account'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKeyValue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 80,
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
                    border: OutlineInputBorder(),
                    labelText: "Enter Name",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                        "Enter College: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
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
                            Text(
                              'SAKEC',
                              style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color: color5),
                            ),
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
                            Text(
                              'OTHER',
                              style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color: color5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isOtherCollegeSelected)
                  Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
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
                          border: OutlineInputBorder(),
                          hintMaxLines: 2,
                          labelText: "Enter College Name",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                TextFormField(
                  controller: studentAccCreationemailController,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Email";
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                    labelText: "Enter Class-Div",
                    hintText: "Enter like Eg. FE-9",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  focusNode: passwordFocusNode,
                  controller: studentAccCreationpasswordController,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Password";
                    return null;
                  },
                  onChanged: (value) {
                    checkPasswordStrength(value); // Real-time check
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Password",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (isPasswordFieldFocused)
                  Column(
                    children: [
                      Row(
                        children: [
                          buildPasswordCriteriaIcon(hasUppercase),
                          SizedBox(width: 10),
                          Text("At least 1 uppercase letter"),
                        ],
                      ),
                      Row(
                        children: [
                          buildPasswordCriteriaIcon(hasSpecialChar),
                          SizedBox(width: 10),
                          Text("At least 1 special character"),
                        ],
                      ),
                      Row(
                        children: [
                          buildPasswordCriteriaIcon(hasNumber),
                          SizedBox(width: 10),
                          Text("At least 1 number"),
                        ],
                      ),
                      Row(
                        children: [
                          buildPasswordCriteriaIcon(hasMinLength),
                          SizedBox(width: 10),
                          Text("8-20 characters long"),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Confirm Password";
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    suffixIcon: buildPasswordCriteriaIcon(isPasswordMatching),
                  ),
                  onChanged: (value) {
                    checkPasswordMatch(value);
                  },
                ),
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        backgroundColor: color5,
                      ),
                      onPressed: isLoading ? null : checkValidation,
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    if (isLoading)
                      const CircularProgressIndicator(
                        color: Colors.white,
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
