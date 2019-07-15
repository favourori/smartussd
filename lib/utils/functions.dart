import 'package:url_launcher/url_launcher.dart';


launchURL(String link) async {
  String url = 'tel:$link';
  if (await canLaunch(url)) {
    print(url);
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<Null> sendAnalytics(analytics, eventName, parameters) async{
  await analytics.logEvent(
    name:"$eventName",
    parameters: parameters,
  ).then((f) =>
      print("event logged")
  );
}