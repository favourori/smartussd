import 'package:flutter/material.dart';
import 'package:kene/control.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nokanda',
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: "Poppins",
        // brightness: Brightness.dark
      ),
      navigatorObservers: [
        observer,
      ],
      home: Control()
    );
  }
}

