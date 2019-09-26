import 'package:flutter/material.dart';


//colors
Color primaryColor = Colors.purple;
Color primaryColorDark = Colors.black;
Color secondaryCOlor = Colors.red;
Color accentCOlor = Colors.red;
Color pageBackground = Colors.grey[300];
Color mainColor = Color(0xffED7937);



//fonts
var bigTitle = TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold);
var appBarheading = TextStyle(color: Colors.white, fontSize: 20);
var heading = TextStyle(color: Colors.black, fontSize: 18);
var headingWhite = TextStyle(color: Colors.white, fontSize: 18);
var headingBold = TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
var drawerHeader = TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold);
var headingBoldWhite = TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
var subHeading = TextStyle(color: Colors.black, fontSize: 16);
var label = TextStyle(color: Colors.black, fontSize: 12);
var normalText = TextStyle(color: Colors.black, fontSize: 14);
var normalTextWhite = TextStyle(color: Colors.white, fontSize: 14);
var btnTextNormalWhite = TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
// var heading = TextStyle(color: Colors.black, fontSize: 18);


//spacing

var paddingMain = EdgeInsets.all(20);


AppBar appBar(title){
return AppBar(
        // backgroundColor: ,
        centerTitle: true,
        title: Text("$title", style: appBarheading),
      );
}