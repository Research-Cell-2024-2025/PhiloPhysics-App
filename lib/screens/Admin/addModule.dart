import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/services/moduleServices.dart';
import 'package:ephysicsapp/widgets/generalWidgets.dart';
import 'package:flutter/material.dart';

class AddModule extends StatefulWidget {
  AddModule({Key? key}) : super(key: key);
  @override
  _AddModuleState createState() => _AddModuleState();
}

class _AddModuleState extends State<AddModule> {

  var selectedType;
  List sections = ["1", "2"];
  String selectedSection="1";

 TextEditingController moduleNameController = TextEditingController();
  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();

  checkValidation()
  {
    if(_formKeyValue.currentState!.validate()){
     addModule(section:selectedSection,modName:moduleNameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: themeAppBar("Add New Module"),
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
                  title: Text("Physics-I"),
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
                      title: Text("Physics-II"),
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
                    return "Enter module name";
                  else return null;
                },
                decoration: InputDecoration(
                  labelText: "Enter Module name",
                  fillColor: Colors.white,
                  
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide( width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                child: Text(
                  'Create Module',
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
