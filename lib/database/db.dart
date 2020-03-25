import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



class KDB{
  String path;
  Database database;
  intiDB() async{
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'kene.db');


    // open the database
     database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Meter (id INTEGER PRIMARY KEY, label TEXT, number TEXT)');

          //create services table
          await db.execute(
              'CREATE TABLE Meter (id INTEGER PRIMARY KEY, carier TEXT, serviceID TEXT, serviceLabel TEXT, code TEXT)');
        });
  }

  delete() async{
    // Delete the database
    await deleteDatabase(path);
  }

  insert(String tag, List<String> values) async{
    // Insert some records in a transaction


    switch(tag){
      case "meter":
        await database.transaction((txn) async {
          int id1 = await txn.rawInsert(
              'INSERT INTO Meter(label, number) VALUES("${values[0]}", "${values[1]}")');
          print('last inserted meter is: $id1');
        });
        break;


      default:
        break;
    }
  }


  /// retrieves the table and returns it
  retrieve(String tag) async{
    // Get the records

    if(tag == "meter"){
      List<Map> list = await database.rawQuery('SELECT * FROM Meter');
      return list;

    }
    else{

    }
  }

  deleteRecord(int id) async{
    // Delete a record
   var  count = await database
        .rawDelete('DELETE FROM Meter WHERE id = $id');
  if(count == 1){
    return true;
  }
  return false;
  }


  Future<int> returnCount(table) async{
    // Count the records
    int count = Sqflite
        .firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM $table'));
    
    return count;
  }

  close() async{
    // Close the database
    await database.close();
  }

 firestoreDelete(String collection, String docId){
      Firestore.instance.collection(collection)
      .document(docId)
      .delete()
      .catchError((err){
          return -1;
      });

    return 1;
  }

  int firestoreAdd(String collection, Map<String, dynamic> data){
    Firestore.instance.collection(collection)
    .add(data)
    .then((d){
      print("saved");
      return 1;
    })
    .catchError((err){
      print("error");
      print(err);
      return -1;
    });
    return 1;
  }
}