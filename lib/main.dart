import 'package:flutter/material.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/homepage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:kene/pages/services.dart';

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
        fontFamily: "Roboto-Mono",
        // brightness: Brightness.dark
      ),
      navigatorObservers: [
        observer,
      ],
      home: Carriers()
      
      // Signin(
      //   analytics: analytics, observer:observer
      //   )

//      Homepage(analytics: analytics, observer:observer),
    );
  }
}
