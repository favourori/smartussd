import 'package:flutter/material.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CustomBottomNavigation extends StatelessWidget {

  final isCurrentPage;

  CustomBottomNavigation({this.isCurrentPage});

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
                  if(isCurrentPage ==  null || !isCurrentPage){
                    Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(pageBuilder: (BuildContext context, Animation animation,
                            Animation secondaryAnimation) {
                          return Carriers();
                        }, transitionsBuilder: (BuildContext context, Animation<double> animation,
                            Animation<double> secondaryAnimation, Widget child) {
                          return new SlideTransition(
                            position: new Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        }),
                            (Route route) => false);
                  }
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
