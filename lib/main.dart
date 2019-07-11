import 'package:flutter/material.dart';
import 'package:kene/pages/homepage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  FirebaseAnalytics analytics = FirebaseAnalytics();
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
      home: Homepage(analytics: analytics, observer:observer),
    );
  }
}
