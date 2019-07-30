import 'package:flutter/cupertino.dart';

class CustomPageRoute extends CupertinoPageRoute {
  final navigateTo;
  CustomPageRoute({this.navigateTo})
      : super(builder: (BuildContext context) => navigateTo);


  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: navigateTo);
  }
}