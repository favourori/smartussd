import 'dart:core';
import 'package:kene/control.dart';
import 'package:kene/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';


class NeedsPermission extends StatefulWidget {
  final analytics;
  final primaryColor;


  NeedsPermission({this.analytics, this.primaryColor});

  @override
  State<StatefulWidget> createState() {
    return NeedsPermissionState();
  }
}

class NeedsPermissionState extends State<NeedsPermission> with WidgetsBindingObserver {

  ScrollController _scrollController;

  listener() {
    if (_scrollController.offset >= 45) {
      _scrollController.jumpTo(45);
    }
  }

  // Data to hold the pages string from fireBase for translations
  var pageData = {};

  String locale = "en";


  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });

    print("new state of the life cycle");
    print(_notification);

    if(_notification == AppLifecycleState.resumed){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Control(analytics: widget.analytics,)));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add the observer

    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(listener);

    getPageData("permissions_page").then((data){
      setState(() {
        pageData = data;
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        bottomNavigationBar: CustomBottomNavigation(),
//        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//        floatingActionButton: CustomFloatingButton(
//          pageData: {},
//
//          locale: "en",analytics: widget.analytics,
//          isCurrentPage: true,
//        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, bool isScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery
                        .of(context)
                        .size
                        .height * 0.175,
                    elevation: 14,
                    pinned: true,
                    floating: true,
                    centerTitle: true,
                    forceElevated: isScrolled,
                    actions: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CustomPageRoute(
                                  navigateTo: Settings(
                                    analytics: widget.analytics,
                                  )));
                        },
                        icon: Container()
//                        Icon(
//                          Icons.more_vert,
//                          color: Colors.white,
//                          size: 30,
//                        ),
                      ),
                    ],
                    title: AutoSizeText(
                      "Nokanda",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 2,
                    ),
                    backgroundColor: widget.primaryColor,
                    leading: Text(""),
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                          color: widget.primaryColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Permission Error",
                              style:
                              TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.175,
                      decoration: BoxDecoration(
                          color: widget.primaryColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 0),
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          // MediaQuery.of(context).size.width - 40,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.75,
                          decoration: BoxDecoration(
                              color: Color(0xfff6f7f9),
                              borderRadius: BorderRadius.circular(40)),
                          child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(getTextFromPageData(pageData, "message", locale), textAlign: TextAlign.center,),

                                  SizedBox(
                                    height: 10,
                                  ),
                                  RaisedButton(
                                    color: Colors.black,
                                    child: Text(getTextFromPageData(pageData, "button", locale), style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      openAppSettings();
                                    },
                                  )
                                ],
                              )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}