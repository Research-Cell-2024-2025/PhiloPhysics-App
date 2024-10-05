import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/services/authentication.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:ephysicsapp/widgets/webDisplay.dart';
import 'package:flutter/material.dart';

Widget quizCard(
    {required int index, required Map quizDetails, required String section, required BuildContext context}) {
  return Container(
      margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
      child:Card(
        elevation:isLoggedIn()?1: 3,
        color: isLoggedIn()?color2: color1,
          shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(isLoggedIn()?0:100)),
    ),
      child:ListTile(  
        
       contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border:
                  new Border(right: new BorderSide(width: 1.0, color: color5))),
          child: quizDetails["quizChapNo"]!= null ? Text(quizDetails["quizChapNo"], style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),) : Icon(Icons.quiz),
        ),
        title: Text(
          
          quizDetails["quizName"].toString(),
          overflow: TextOverflow.visible,
          style: TextStyle(
            color: color5,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing:  isLoggedIn()?IconButton(
              icon:Icon(Icons.delete), 
              onPressed: (){
               onDelete(id: quizDetails["quizID"],section:section,context: context);
              },
              color: color5
              ):null,
        onTap: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuizAppView(formUrl: quizDetails["quizLink"], moduleName: quizDetails["quizName"],)));
        },
      )));
}