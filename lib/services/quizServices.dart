import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

addQuiz({required String section, required String quizName, required String quizLink, required String quizChapNo, required BuildContext context})
{
    var uuid = Uuid();
    String uniqueID = uuid.v1();
    try{
     final databaseReference = FirebaseDatabase.instance.ref();
     databaseReference.child("quiz").child(section).child(uniqueID).set(
       {
        "quizName":quizName,
         "quizChapNo": quizChapNo,
        "quizID":uniqueID,
        "quizLink":quizLink,
       }
     );
     showToast("Added Sucessfully");
     Navigator.pop(context);
    }
    catch(e)
    {
       showToast("Failed");
    }
}

deleteQuiz({required String quizID,required String section})async
{
 try{
  await FirebaseDatabase.instance.ref().child("quiz").child(section).child(quizID).remove();
  showToast("Removed Successfully");
 }
 catch(e){
   showToast("Make sure you're connected to Internet");
 }

}
