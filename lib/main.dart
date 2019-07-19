import 'package:flutter/material.dart';
import 'package:kene/pages/homepage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'auth/signin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kene',
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: "Mali",
        // brightness: Brightness.dark
      ),
      navigatorObservers: [
        observer,
      ],
      home: Signin(
        analytics: analytics, observer:observer
        )

//      Homepage(analytics: analytics, observer:observer),
    );
  }
}
