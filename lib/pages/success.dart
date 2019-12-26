import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:kene/utils/functions.dart';

class SuccessPage extends StatefulWidget {
  @override
  createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  ScrollController _scrollController;
  RateMyApp _rateMyApp;

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
  }

  handleRate() {
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

  @override
  build(context) {
    return Scaffold(
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
                      "Thanks for using Nokanda",
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
                          "Thanks for using Nokanda, please share with friends and family",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            pageButtons("Home", () {
                              Navigator.pushReplacement(context, CustomPageRoute(navigateTo: Carriers()));
                            }, Icons.home, context),
                            SizedBox(
                              width: 15,
                            ),
                            pageButtons("Redo", () {
                              Navigator.pop(context);
                            }, Icons.loop, context)
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            pageButtons("Share", () {
                              share();
                            }, Icons.share, context),
                            SizedBox(
                              width: 15,
                            ),
                            pageButtons("Rate", () {
                              handleRate();
                            }, Icons.rate_review, context)
                          ],
                        ),
                        SizedBox(
                          height: 20,
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

  RaisedButton pageButtons(
      String label, Function onPressedAction, IconData icon, context) {
    return RaisedButton(
      color: Color(0xff1C1766),
      splashColor: Colors.orangeAccent,
      padding: EdgeInsets.symmetric(
          vertical: 5, horizontal: MediaQuery.of(context).size.width * 0.15),
      onPressed: onPressedAction,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
