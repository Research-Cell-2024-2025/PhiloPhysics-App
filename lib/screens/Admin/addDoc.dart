import 'dart:io';
import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/services/docServices.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

class AddDoc extends StatefulWidget {
  AddDoc({Key? key, required this.section, required this.moduleID}) : super(key: key);
  final String section;
  final String moduleID;

  @override
  _AddDocState createState() => _AddDocState();
}

class _AddDocState extends State<AddDoc> {
  String filePath = "";
  late File pickedFile;
  TextEditingController docNameController = TextEditingController();
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  // Method to pick a file
  onFilePick() async {
    final params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      sourceType: SourceType.photoLibrary,
      fileExtensionsFilter: ["pdf"],
    );

    try {
      filePath = (await FlutterFileDialog.pickFile(params: params))!;
      print("File path: $filePath");
      setState(() {});
    } catch (e) {
      print("Error picking file: $e");
      showToast("Error picking file: $e");
    }
  }

  // Method to handle the document upload process
  Future getFuture() {
    return Future(() async {
      await addDoc(section: widget.section, moduleID: widget.moduleID, docName: docNameController.text, doc: pickedFile);
      Navigator.pop(context);
      return 'Process Complete';
    });
  }

  // Method to validate the form and show progress
  checkValidation() {
    if (_formKeyValue.currentState!.validate() && filePath.isNotEmpty) {
      pickedFile = File(filePath);
      if (pickedFile.existsSync()) {
        debugPrint("File exists at: $filePath");
        showProgress(context);
      } else {
        showToast("Selected file does not exist.");
        print("File does not exist at: $filePath");
      }
    } else {
      showToast("Please enter details and select a file.");
    }
  }

  // Method to show progress dialog
  Future<void> showProgress(BuildContext context) async {
    var result = await showDialog(
        builder: (context) => FutureProgressDialog(getFuture(), message: Text('Uploading...')),
        context: context);
    showResultDialog(context, result);
  }

  // Method to extract the file name from the file path
  String getFileName(String? path) {
    if (path == null) return "";
    return path.split('/').last;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: color1,
      appBar: AppBar(
        title: Text("Add Document"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKeyValue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: docNameController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter document name";
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Enter document name",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onFilePick();
                },
                child: Text("Select file"),
              ),
              Text("Selected file: ${getFileName(filePath)}"),  // Display only the file name
              SizedBox(height: 30),
              ElevatedButton(
                child: Text(
                  'Add Document',
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
      ),
    );
  }
}
