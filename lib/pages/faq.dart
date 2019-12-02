import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kene/widgets/collapsible_widget.dart';

class FAQ extends StatelessWidget{
  @override
  Widget build(context){
    return Platform.isIOS ?
    CupertinoApp(
      theme: CupertinoThemeData(
        primaryColor: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.activeOrange,

          child:
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height:30,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(child: Icon(Icons.arrow_back_ios, size: 24, color: Colors.white,), onTap: (){
                              Navigator.pop(context);
                            }),
                          )
                      ),

                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text("FAQ", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20,
                              fontFamily: "Poppins",
                              color: CupertinoColors.white
                          ),),
                        ),),

                      Expanded(
                        flex: 1,
                        child: Container(),
                      )
                    ],
                  ),

                  SizedBox(height: 30,),

                  StreamBuilder(
                    stream: Firestore.instance.collection("settings/faq/faqs").orderBy("orderNo").snapshots(),
                      builder:(context, snapshot){
                          if(!snapshot.hasData)
                            return Container(
                              child: Text("Loading ...", style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppins",
                              ),),
                            );
                          return ListView(
                            shrinkWrap: true,
                            children:populateQuestions(snapshot.data.documents)
                          );
                  })
                ],
              ),
            ),
          )
      ),
    )
    :
    
    Scaffold(
      backgroundColor: CupertinoColors.activeOrange,
//      appBar: AppBar(
//        title: Text("FAQ"),
//      ),
      body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height:30,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(child: Icon(Icons.arrow_back_ios, size: 24, color: Colors.white,), onTap: (){
                              Navigator.pop(context);
                            }),
                          )
                      ),

                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text("FAQ", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20,
                              fontFamily: "Poppins",
                              color: CupertinoColors.white
                          ),),
                        ),),

                      Expanded(
                        flex: 1,
                        child: Container(),
                      )
                    ],
                  ),

                  SizedBox(height: 30,),

                  StreamBuilder(
                      stream: Firestore.instance.collection("settings/faq/faqs").orderBy("orderNo").snapshots(),
                      builder:(context, snapshot){
                        if(!snapshot.hasData)
                          return Container(
                            child: Text("Loading ...", style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                            ),),
                          );
                        return ListView(
                            shrinkWrap: true,
                            children:populateQuestions(snapshot.data.documents)
                        );
                      })
                ],
              ),
            ),
          )
      ),
    );
  }

  List<Widget> populateQuestions(list){
    List<Widget> tmp = [];

    for(var item in list){
      tmp.add(
        CollapsibleWidget(question: item["question"], answer: item['answer'],),
      );
    }

    return tmp;
  }

}

