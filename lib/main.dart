import 'package:flutter/material.dart';
import 'package:kene/control.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:kene/widgets/bloc_provider.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  static FirebaseAnalytics xAnalytics = FirebaseAnalytics();
  final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: xAnalytics);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nokanda',
          theme: ThemeData(
            primaryColor: Colors.black,
            fontFamily: regularTextFamily
            // brightness: Brightness.darkxs
          ),
          navigatorObservers: [
            observer,
          ],
          home: Control(analytics: xAnalytics,)
      ),
    );
  }
}

