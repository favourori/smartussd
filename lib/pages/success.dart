import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kene/components/CustomFloatingButton.dart';
import 'package:kene/components/bottom_navigation.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:kene/utils/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SuccessPage extends StatefulWidget {
  @override
  createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  ScrollController _scrollController;
  RateMyApp _rateMyApp;


  var analytics = FirebaseAnalytics();

  String locale = "en";

  Map pageData = {};


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0);

    _rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 1000000,
      minLaunches: 1000000,
      remindDays: 1000000,
      remindLaunches: 1000000,
    );



    var appBloc = BlocProvider.of(context);

    appBloc.localeOut.listen((data) {
      setState(() {
        locale = data != null ? data : locale;
      });
    });


    getPageData("success_page").then((data){
      setState(() {
        pageData = data;
      });
    });

  }

  handleRate() {
    if(Platform.isIOS){
      upDateButtonAction();
    }
    else {
      _rateMyApp.init().then((_) {
        _rateMyApp.showRateDialog(
          context,
          title: 'Rate this app',
          message:
          'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
          rateButton: 'RATE',
          noButton: 'NO THANKS',
          laterButton: '',
          ignoreIOS: false,
          dialogStyle: DialogStyle(),
        );
      });
    }
  }


 String makeTweetText(){
    String tweet = getTextFromPageData(pageData, "tweet", locale);
    String tweetToSend = "";

    for(int i=0; i < tweet.length; i++){
      if(tweet[i] == " "){
        tweetToSend += "%20";
      }
      else{
        tweetToSend += tweet[i];
      }
    }

    return tweetToSend;

  }

  @override
  build(context) {
    return Scaffold(
        bottomNavigationBar: CustomBottomNavigation(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: CustomFloatingButton(pageData: {}, analytics: analytics, locale: locale,),
        body: NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, bool isScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.175,
            elevation: 14,
            pinned: true,
            floating: true,
            centerTitle: true,
            forceElevated: isScrolled,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context, CustomPageRoute(navigateTo: Settings()));
                },
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 30,
                ),
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
            backgroundColor: Colors.orange,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      getTextFromPageData(pageData, "title", locale),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
          )
        ];
      },
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.175,
              decoration: BoxDecoration(
                  color: Colors.orange,

              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[],
              ),
            ),
            Positioned(
              top: 0,
              // MediaQuery.of(context).size.height * 0.35,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.72,
                  decoration: BoxDecoration(
                      color: Colors.white,

                      // Color(0xffE3E1E1),
                      borderRadius: BorderRadius.circular(40)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          getTextFromPageData(pageData, "sub_title", locale),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30, 
                        ),
//                        Row(
////                          mainAxisAlignment: MainAxisAlignment.center,
////                          children: <Widget>[
////
////                            SizedBox(
////                              width: 15,
////                            ),
//////                            pageButtons(getTextFromPageData(pageData, "redo", locale), () {
//////                              Navigator.pop(context);
//////                            }, Icons.loop, context, true)
////
////                            Row(
////                              mainAxisAlignment: MainAxisAlignment.center,
////                              children: <Widget>[
////                                pageButtons("Tweet Nokanda", () async{
////                                  var url =
////                                      'https://twitter.com/intent/tweet?hashtags=Nokanda&text=${makeTweetText()}';
////                                  if (await canLaunch(url)) {
////                                    if (await launch(
////                                      url,
////                                      forceSafariVC: false,
////                                      universalLinksOnly: true,
////                                    )) {
////                                      // print("tweeted");
////                                    } else {
////                                      // print("no apppp");
////                                      await launch(url);
////                                    }
////                                  } else {
////                                    throw 'Could not launch $url';
////                                  }
////                                }, FontAwesomeIcons.twitter, context, true),
////
////                              ],
////                            ),
////
////                          ],
////                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            pageButtons(getTextFromPageData(pageData, "redo", locale), () async{
                              Navigator.pop(context);
                            }, Icons.loop, context, true),

                          ],
                        ),

                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            pageButtons(getTextFromPageData(pageData, "share", locale), () {
                              share();
                            }, Icons.share, context, false),
                            SizedBox(
                              width: 15,
                            ),
                            pageButtons(getTextFromPageData(pageData, "rate", locale), () {
                              handleRate();
                            }, Icons.rate_review, context, false)
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            pageButtons(getTextFromPageData(pageData, "tweet", locale), () async{
                              var url =
                                  'https://twitter.com/intent/tweet?hashtags=Nokanda&text=${makeTweetText()}';
                              if (await canLaunch(url)) {
                              if (await launch(
                              url,
                              forceSafariVC: false,
                              universalLinksOnly: true,
                              )) {
                              // print("tweeted");
                              } else {
                              // print("no apppp");
                              await launch(url);
                              }
                              } else {
                              throw 'Could not launch $url';
                              }
                            }, FontAwesomeIcons.twitter, context, true),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  Widget pageButtons(
      String label, Function onPressedAction, IconData icon, context, bool fullWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 5, horizontal: MediaQuery.of(context).size.width * 0.15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(serviceItemBorderRadius),
          boxShadow: [
          buttonBoxShadow
        ]
      ),
      height: 55,
      width: fullWidth ? MediaQuery.of(context).size.width * 0.88 : MediaQuery.of(context).size.width * 0.42,
      child: GestureDetector(
        onTap: onPressedAction,
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: accentColor,
            ),

            Expanded(child: Text(
              label,
//              maxFontSize: 14,
//              minFontSize: 11,
              style: TextStyle(
                color: accentColor,
              ),
            ))
          ],
        ),
      ),
    );
  }
}
