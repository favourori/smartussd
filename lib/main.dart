import 'package:flutter/material.dart';
import 'package:kene/control.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  static FirebaseAnalytics xanalytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: xanalytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nokanda',
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: "Poppins",
        // brightness: Brightness.darkxs
      ),
      navigatorObservers: [
        observer,
      ],
      home: Control(analytics: xanalytics,)
    );
  }
}

