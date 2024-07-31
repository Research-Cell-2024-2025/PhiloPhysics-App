import 'package:ephysicsapp/globals/labels.dart';
import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/services/authentication.dart';
import 'package:ephysicsapp/widgets/generalWidgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLogin extends StatefulWidget {
  AdminLogin({Key? key}) : super(key: key);
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {

 

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();

  checkValidation()
  {
    if(_formKeyValue.currentState!.validate()){
     login(emailController.text,passwordController.text,context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: themeAppBar("Login"),
      body: Center(child: SingleChildScrollView(child:Container(
        padding: EdgeInsets.symmetric(horizontal:20),
        child:Form(
          key: _formKeyValue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

             Text(
                loginPage,
                style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: color5),
              ),
 SizedBox(height: 30,),
               TextFormField(
                controller: emailController,
                validator: (value){
                  if(value!.isEmpty)
                    return "Enter Email";
                  else return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Enter Email",
                  fillColor: Colors.white,
                  
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide( width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: passwordController,
                validator: (value){
                  if(value!.isEmpty)
                    return "Enter Password";
                  else return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Enter Passwords",
                  fillColor: Colors.white,
                  
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 30,),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), backgroundColor: color5,
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
      
    ))));
  }
}
