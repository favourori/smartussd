import 'package:flutter/material.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CustomBottomNavigation extends StatelessWidget {

  final Widget svgIcon = SvgPicture.asset(
      "assets/images/hexakomb_full_logo.svg",
      color: mainColor,
      height: 40,
      semanticsLabel: 'hexakomb logo'
  );


  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
//        color: Colors.orangeAccent,
      elevation: 14,
      child: Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(context, CustomPageRoute(navigateTo: Carriers()));
                },
                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 30,
                    ),
                    Icon(Icons.home, color: mainColor, size: 30,),
//                    SizedBox(width: 3,),
//                    Text("Home", style: TextStyle(color: mainColor, fontSize: 12, fontFamily: buttonTextFamily, fontWeight: FontWeight.bold),)
                  ],
                ),
              )
            ),

            Expanded(
                flex: 1,

                child: Container(
                  child: svgIcon,
//                  decoration: BoxDecoration(
//                      image: DecorationImage(image: AssetImage("assets/images/hexakomb_full_logo.png"))
//                  ),
                )
            ),

            Expanded(
              flex: 1,
              child: Text("", textAlign: TextAlign.center, style: TextStyle(
                  color: Colors.white,
                  fontSize: 12
              ),),
            )

          ],
        ),
      ),      );
  }
}
