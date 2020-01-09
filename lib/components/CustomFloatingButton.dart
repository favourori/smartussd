import 'package:flutter/material.dart';
import 'package:kene/pages/shortcuts.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/custom_nav.dart';


class CustomFloatingButton extends StatelessWidget {
  final pageData;
  final locale;
  final analytics;

  CustomFloatingButton({this.pageData, this.locale, this.analytics});

  @override
  Widget build(BuildContext context) {
    return  FloatingActionButton(
      backgroundColor: Color(0xfff6f7f9),
      child: Icon(Icons.favorite, size: 30, color:  mainColor,),
      onPressed: () async{
        var uid = await getUserID();
        Navigator.push(context,  CustomPageRoute(
            navigateTo: NShortcuts(
              userID:uid,
              primaryColor: Colors.orangeAccent,
              carrierTitle: getTextFromPageData(pageData, "shortcuts", locale),
              analytics: analytics,
            )
        ));
//          Navigator.push(context, CustomPageRoute(
//            navigateTo: ReceivePage(qrImage: _qrScan, analytics: widget.analytics,)

//          ));
      },
    );
  }
}
