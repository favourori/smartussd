import 'package:flutter/material.dart';
import 'package:kene/database/db.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:sqflite/sqflite.dart';



class Addons extends StatefulWidget {
  @override
  _AddonsState createState() => _AddonsState();
}

class _AddonsState extends State<Addons> {

  TextEditingController _meterController = TextEditingController();
  TextEditingController _labelController = TextEditingController();

  List<Widget> meterList = [];
  double _widthAnimate = 0;


  KDB db = KDB();

  @override
  initState(){
    super.initState();
    printRecord();
  }

  ScrollController _listViewController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: Text("Addons"),
      ),
      body: ListView(
        children: <Widget>[
          
          Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: 20),
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Form(
              child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Add meter numbers", style: headingBold,),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _labelController,
                        decoration: InputDecoration(
                          labelText: "Enter label e.g home, mom, office",
                          labelStyle: label
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _meterController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: "Enter meter number",
                            labelStyle: label
                        ),
                      ),
                    ),
                    Spacer(),
                    
                    Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        child: RaisedButton(
                          color: Colors.orange,
                          onPressed: (){
                            meterAdd();
                          },
                          child: Text("Add", style: normalTextWhite,),
                        ),
                      ),
                    ),
                  ],
              ),
            ),
          ),

          Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 20),
                child: Text("Saved Meter Numbers", style: heading,),),
            ],
          ),

          Column(

            children: meterList,
          ),
          
        ],
      controller: _listViewController,),
    );
  }

  meterAdd() async{
    List<String> values  = [];
    values.add(_labelController.text);
    values.add(_meterController.text);

    await db.intiDB().then((f) =>
      db.insert("meter", values).then((f) =>
        printRecord().then((ff) =>
          updateText()
        )
      )
    );

  }

  updateText(){
    setState(() {
      _labelController.text = "";
      _meterController.text = "";
    });
  }

  printRecord() async{
    List<Widget> temp = [];
    await db.intiDB();
    var res = await db.retrieve("meter");

    print(res);

    for(Map x in res){
      temp.add(
        GestureDetector(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            curve: Curves.linearToEaseOut,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            width: 300 - _widthAnimate,
            height: 60,
            margin: EdgeInsets.only(bottom: 5, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              children: <Widget>[
                Expanded(
            flex: 5,
              child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("${x['label']}"),
                    Text("${x['number']}")
                  ],
                ),),

                Expanded(flex: 2,
                  child:Padding(
                  padding: EdgeInsets.all(0),
                  child: IconButton(icon: Icon(Icons.delete_outline, color: Colors.redAccent,), onPressed: () async{
                    var hasDeleted = await db.deleteRecord(x['id']);
                    if(hasDeleted){
                      printRecord();
                    }
                  }),
                ))
              ],
            ),
          ),
        )
      );
    }

    setState(() {
      meterList = temp;
    });
  }
}
