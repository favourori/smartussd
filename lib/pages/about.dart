import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:kene/utils/functions.dart';


class About extends StatelessWidget {
  final analytics;
  About({this.analytics});

  @override
  Widget build(BuildContext context) {


    // Send analytics on page load/initialize
    sendAnalytics(analytics, "AboutPage_Open", null);
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height*0.3,
                color: Colors.orange,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.1,
                    ),

                    AutoSizeText("About", style:TextStyle(
                      color:Colors.white,
                      fontSize:28,

                    ),

                      maxLines: 2,)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3.0, top: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.68,
                  child: Center(
                    child: StreamBuilder(
                      stream: Firestore.instance.collection("settings").snapshots(),
                        builder: (context, snapshot){
                          String aboutText="";
                          for(var item in snapshot.data.documents){
                            print(item.documentID);
                            if(item.documentID == "about"){
                              aboutText = item['text'];

                            }
                          }
                      return Text("$aboutText", textAlign: TextAlign.justify,);
                    }),
                  )
                ),
              )
            ],
          )),
    );
  }


}