import 'dart:async';
import 'dart:io';
import 'package:ephysicsapp/widgets/pdfViewer.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';



addDoc({required String section, required String moduleID, required String docName, required File doc}) async {
  var uuid = Uuid();
  String uniqueID = uuid.v1();
  late String downloadUrl;
  try {
    var storageReference =
        FirebaseStorage.instance.ref().child("$section/$moduleID/$uniqueID");
    var uploadTask = storageReference.putFile(doc);
    await uploadTask.whenComplete(() async {
      await storageReference.getDownloadURL().then((fileURL) {
        downloadUrl = fileURL;
      });
    });

    final databaseReference = FirebaseDatabase.instance.ref();
    await databaseReference
        .child(section)
        .child(moduleID)
        .child("documents")
        .child(uniqueID)
        .set({
      "docName": docName,
      "docID": uniqueID,
      "downloadUrl": downloadUrl,
    });
    showToast("Added Sucessfully");
  } catch (e) {
    print(e);
    showToast("Failed to add Video");
  }
}



Future<void> addVideo({
  required String section,
  required String moduleID,
  required String docName,
  required String docLink,
  required String thumbnailLink,
  required BuildContext context,
}) async {
  var uuid = Uuid();
  String uniqueID = uuid.v1();

  try {
    // Convert the YouTube shortened URL to a standard format if needed
    String formattedDocLink = _convertYouTubeLink(docLink);

    final databaseReference = FirebaseDatabase.instance.ref();
    await databaseReference
        .child(section)
        .child(moduleID)
        .child("videos")
        .child(uniqueID)
        .set({
      "videoName": docName,
      "docID": uniqueID,
      "videoDownloadUrl": formattedDocLink, // Use the formatted link
      "thumbnailDownloadUrl": thumbnailLink,
    });
    print(docLink);
    print(formattedDocLink);
    showToast("Video Added Successfully");
    print("$formattedDocLink && $thumbnailLink");
    Navigator.pop(context);
  } catch (e) {
    print(e);
    showToast("Failed");
  }
}

// Helper function to convert YouTube link
String _convertYouTubeLink(String link) {
  // Check if it's a shortened YouTube URL
  if (link.contains("youtu.be")) {
    // Extract the video ID from the shortened URL
    var uri = Uri.parse(link);
    String videoID = uri.pathSegments.last;
    // Construct the full YouTube URL
    return "https://www.youtube.com/watch?v=$videoID";
  }
  // Return the original link if it's not a shortened URL
  return link;
}



deleteDoc({required String docID, required String moduleID, required String section}) async {
  var storageReference =
      FirebaseStorage.instance.ref().child("$section/$moduleID/" + docID);
  var uploadTask = storageReference.delete();
  await uploadTask.whenComplete(() async {
    await FirebaseDatabase.instance
        .ref()
        .child(section)
        .child(moduleID)
        .child("documents")
        .child(docID)
        .remove();
    showToast("Removed Successfully");
  });
}

Future<void> openFile(String url, BuildContext context,String title) async {

  // ProgressDialog _progressDialog = ProgressDialog();
  // _progressDialog.showProgressDialog(
  //   context,textToBeDisplayed: 'Opening...',
  //
  //   dismissAfter: Duration(seconds: 5));

  String remotePDFpath = "";
  createFileOfPdfUrl(url).then((f) {
    remotePDFpath = f.path;

    if (remotePDFpath != null || remotePDFpath.isNotEmpty) {
     //  _progressDialog.dismissProgressDialog(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFScreen(path: remotePDFpath,title: title,),
        ),
      );
    }

  });
}

Future<File> createFileOfPdfUrl(String pdfUrl) async {
  Completer<File> completer = Completer();
  print("Start download file from internet!");
  try {
    // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
    // final url = "https://pdfkit.org/docs/guide.pdf";
    final url = pdfUrl;
    final filename = url.substring(url.lastIndexOf("/") + 1);

    var dir = await getApplicationDocumentsDirectory();
    print("${dir.path}/$filename");
    File file = File("${dir.path}/$filename");

    if(!(await file.exists())){
    print("--------------------doesnt  exist");
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    await file.writeAsBytes(bytes, flush: true);
    }
    else print("--------------------Already exist");
   
    completer.complete(file);
  } catch (e) {
    throw Exception('Error parsing asset file!');
  }

  return completer.future;
}

//  Future getFuture(String url,BuildContext context) {
//     return Future(() async {
//       await openFile( url,context);
//       return 'Read File';
//     });
//   }

// Future<void> openDocProgressIndicator(BuildContext context,String url) async {
//     var result = await showDialog(
//         context: context,
//         child: FutureProgressDialog(getFuture(url,context), message: Text('Opening File...')));
//     showResultDialog(context, result);
//   }




// fetchDocs(String section,String moduleID ) async{
// var connectivityResult = await (Connectivity().checkConnectivity());
// if (connectivityResult != ConnectivityResult.none) {
//   final databaseReference = FirebaseDatabase.instance.reference();
//  databaseReference.child(section).child(moduleID).child("documents").once().then((value){


//    return value.value;
//  });

//   }
// else if (connectivityResult == ConnectivityResult.none) {

//   }
// }