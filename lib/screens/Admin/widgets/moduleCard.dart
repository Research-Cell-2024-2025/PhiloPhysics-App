import 'package:ephysicsapp/globals/colors.dart';
import 'package:ephysicsapp/screens/Admin/docMaster.dart';
import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:flutter/material.dart';

Widget moduleCard({
  required int index,
  required Map<dynamic, dynamic> moduleDetails,
  required String section,
  required BuildContext context,
}) {
  final String moduleName = moduleDetails['moduleName'] ?? 'Unknown';
  final String moduleId = moduleDetails['moduleId'] ?? 'Unknown';
  final int moduleNo = moduleDetails['moduleNo'] ?? 'Unknown';

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocMaster(
            section: section,
            moduleName: moduleName,
            moduleID: moduleId,
          ),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
      child: Card(
        elevation: 3,
        color: color2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
        ),
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(width: 1.0, color: color5)),
            ),
            child: Text(
              moduleNo.toString(),
              style: TextStyle(fontSize: 18),
            ),
          ),
          title: Text(
            moduleName,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: color5,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            color: color5,
            onPressed: () {
              print(moduleDetails);
              onModuleDelete(
                  section: section,
                  moduleID: moduleDetails["moduleId"]!.toString(),
                  context: context,
                  moduleDetails: moduleDetails);
            },
          ),
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => DocMaster(
          //         section: section,
          //         moduleName: moduleName,
          //         moduleID: moduleId,
          //       ),
          //     ),
          //   );
        ),
      ),
    ),
  );
}
