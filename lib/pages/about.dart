import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/bloc_provider.dart';


class About extends StatefulWidget {
  final analytics;

  About({this.analytics});

  @override
  State<StatefulWidget> createState() {
    return _AboutState();
  }

}


class _AboutState extends State<About>{


  String locale = "en";
  Map pageData = {};

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


    getPageData("about_page").then((data){
      setState(() {
        pageData = data;
      });
    });

  }
  @override
  Widget build(BuildContext context) {


    // Send analytics on page load/initialize
    sendAnalytics(widget.analytics, "AboutPage_Open", null);
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
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.1,
                    ),

                    AutoSizeText(getTextFromPageData(pageData, "title", locale), style:TextStyle(
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
                    child:  Text(getTextFromPageData(pageData, "page_text", locale), textAlign: TextAlign.justify,)
                    ,
                  )
                ),
              )
            ],
          )),
    );
  }


}