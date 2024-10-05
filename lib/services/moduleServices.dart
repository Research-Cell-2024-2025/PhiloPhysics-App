

import 'package:ephysicsapp/widgets/popUps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

addModule({required String section, required String modName})
{
    var uuid = Uuid();
    String uniqueID = uuid.v1();
    try{
     final databaseReference = FirebaseDatabase.instance.ref();
     databaseReference.child(section).child(uniqueID).set(
       {
        "moduleName":modName,
        "moduleID":uniqueID,
       }
     );
     showToast("Added Sucessfully");
    }
    catch(e)
    {
       showToast("Failed");
    }
}


deleteModule({required String moduleID,required String section,required Map moduleDetails})async
{
  if(moduleDetails.containsKey("documents"))
    showToast("Empty the folder first");
  else{
  await FirebaseDatabase.instance.ref().child(section).child(moduleID).remove();
  showToast("Removed Successfully");
  }
}

deleteVideo({required String moduleID,required String section,required Map moduleDetails})async
{
  if(moduleDetails.containsKey("documents"))
    showToast("Empty the folder first");
  else{
    await FirebaseDatabase.instance.ref().child(section).child(moduleID).remove();
    showToast("Removed Successfully");
  }
}