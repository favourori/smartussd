import 'package:flutter/material.dart';
import 'package:kene/pages/services.dart';
import 'package:kene/widgets/custom_nav.dart';

class Cariers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CariersState();
  }
}

class _CariersState extends State<Cariers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.55,
              decoration: BoxDecoration(
                  color: Color(0xffC89191),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.2,
                  ),
                  // Align(
                  // //   alignment: Alignment.topLeft,
                  // //   child: IconButton(
                  // //     onPressed: () {},
                  // //     icon: Icon(
                  // //       Icons.menu,
                  // //       color: Colors.white,
                  // //       size: 30,
                  // //     ),
                  // //   ),
                  // // ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Choose Network \nService",
                      textAlign: TextAlign.center ,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.55,
                  decoration: BoxDecoration(
                      color: Color(0xffE3E1E1),
                      borderRadius: BorderRadius.circular(40)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: <Widget>[
                        buildServiceListItem("Mtn", Color(0xffE0C537), "00001"),
                        buildServiceListItem("Airtel", Color(0xffED3737), "00002"),
                        // buildServiceListItem("Buy Electricity", "electricity.png"),
                        // buildServiceListItem("Pay water", "bank.ico"),
                        // buildServiceListItem("Check airtime balance", "balance.png")
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  GestureDetector buildServiceListItem(String label, var color, String carierID) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, CustomPageRoute(navigateTo:Services(carierId: carierID,)));
      },
          child: Container(
        margin: EdgeInsets.only(bottom: 10),
        height: 60,
        decoration: BoxDecoration(
            color: color,
             borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Center(
            child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),),
                ),
          )
        ),
      ),
    );
  }
}
