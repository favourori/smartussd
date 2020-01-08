import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:kene/widgets/collapsible_widget.dart';
import 'package:kene/utils/stylesguide.dart';

class FAQ extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _FAQState();
  }
}




class _FAQState extends State<FAQ>{

  String locale;

  @override
  void initState() {
    super.initState();


    var appBloc;

    appBloc = BlocProvider.of(context);

    appBloc.localeOut.listen((data) {
      setState(() {
        locale = data != null ? data : locale;
      });
    });

  }


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
                              fontFamily: regularTextFamily,
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
                                fontFamily: regularTextFamily,
                              ),),
                            );
                          return ListView(
                            shrinkWrap: true,
                            children:populateQuestions(filterActiveFAQs(snapshot.data.documents))
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
                              fontFamily: regularTextFamily,
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
                              fontFamily: regularTextFamily,
                            ),),
                          );
                        return ListView(
                            shrinkWrap: true,
                            children:populateQuestions(filterActiveFAQs(snapshot.data.documents))
                        );
                      })
                ],
              ),
            ),
          )
      ),
    );
  }

  filterActiveFAQs(List list){
    var activeFilteredList = [];
    for(var faq in list){
      if(faq['isActive'] != null && faq['isActive']){
        activeFilteredList.add(faq);
      }
    }


    return activeFilteredList;
  }

  List<Widget> populateQuestions(list){
    List<Widget> tmp = [];

    for(var item in list){
      tmp.add(
        CollapsibleWidget(question: item['question_map'] != null ? item['question_map'][locale] :  item["question"],
          answer: item['answer_map'] != null ? item['answer_map'][locale] : item['answer'],),
      );
    }

    return tmp;
  }

}

