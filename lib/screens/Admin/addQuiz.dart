import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/services/quizServices.dart';
import 'package:ephysicsapp/widgets/generalWidgets.dart';
import 'package:flutter/material.dart';

class AddQuiz extends StatefulWidget {
  final String? title; // Making title nullable

  AddQuiz({Key? key, this.title}) : super(key: key);

  @override
  _AddQuizState createState() => _AddQuizState();
}

class _AddQuizState extends State<AddQuiz> {

  var selectedType;
  List sections = ["1", "2"];
  String selectedSection="1";

  TextEditingController moduleNameController = TextEditingController();
  TextEditingController moduleNoController = TextEditingController();
  TextEditingController quizLinkController = TextEditingController();
  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();

  checkValidation()
  {
    if(_formKeyValue.currentState!.validate()){
    
     addQuiz(section:selectedSection,quizName:moduleNameController.text,quizLink: quizLinkController.text, quizChapNo:moduleNoController.text, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: themeAppBar("Add New Quiz"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal:20),
        child:Form(
          key: _formKeyValue,
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           Row(children: <Widget>[
                Flexible(
                    child: ListTile(
                  title: Text("SAKEC"),
                  leading: Radio<String>(
                    value: sections[0],
                    groupValue: selectedSection,
                    onChanged: (value) {
                      setState(() {
                        selectedSection = value!;
                      });
                    },
                  ),
                )),
                Flexible(
                  child: ListTile(
                      title: Text("OTHERS"),
                      leading: Radio<String>(
                        value: sections[1],
                        groupValue: selectedSection,
                        onChanged: (value) {
                          setState(() {
                            selectedSection = value!;
                          });
                        },
                      )),
                ),
              ]),
              TextFormField(
                controller: moduleNameController,
                validator: (value){
                  if(value!.isEmpty)
                    return "Enter Quiz name";
                  else return null;
                },
                decoration: InputDecoration(
                  labelText: "Enter Quiz name",
                  fillColor: Colors.white,
                  
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide( width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20,),
            TextFormField(
              controller: moduleNoController,
              validator: (value){
                if(value!.isEmpty)
                  return "Enter Quiz Chapter No";
                else return null;
              },
              decoration: InputDecoration(
                labelText: "Enter Quiz Chapter No",
                fillColor: Colors.white,

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide( width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 20,),
              TextFormField(
                controller: quizLinkController,
                validator: (value){
                  if(value!.isEmpty)
                    return "Enter Quiz Link";
                  else return null;
                },
                maxLines: 4,
                minLines: 2,
                decoration: InputDecoration(
                  labelText: "Enter Quiz Link",
                  fillColor: Colors.white,
                  
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide( width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                child: Text(
                  'Create Quiz',
                  style: TextStyle(color: color1),
                ),
                onPressed: () {
                  checkValidation();
                },
                style: ElevatedButton.styleFrom(backgroundColor: color4),
              ),
          ],
        ),
      ),
      
    ));
  }
}
