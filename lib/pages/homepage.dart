import 'package:flutter/material.dart';
import 'package:kene/pages/addons.dart';
import 'package:kene/pages/mtn_options.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/utils/stylesguide.dart';
//import 'package:advanced_share/advanced_share.dart';
//import 'package:firebase_analytics/observer.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';

class Homepage extends StatefulWidget {
  final observer;
  final analytics;

  Homepage({this.analytics, this.observer});

  @override
  _HomepageState createState() => _HomepageState();
} 

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin{
  TabController tabController;

  String buttonNameClicked = "";

  Future<Null> _appOpen() async{
    await widget.analytics.logAppOpen(
    ).then((f) =>
        print("app open event logged")
    );
  }

  Future<Null> _currentScreen() async{
       await widget.analytics.setCurrentScreen(
         screenName:"Homepage",
         screenClassOveride:"HomePage"
       );
  }

  @override
  initState(){
    super.initState();
    tabController = TabController(length: 2, vsync: this);
//    _currentScreen();
  sendAnalytics(widget.analytics, "home_screen_opened", null);
  _appOpen();
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Kene Smart USSD"),
        bottom: TabBar(
          controller: tabController,
          tabs: <Widget>[
            Tab(
              text: "MTN",
            ),
            Tab(
              text: "AIRTEL",
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
           Expanded(
             flex: 3,
             child:           DrawerHeader(
                 child: Container(
                     decoration: BoxDecoration(
//                  color: Colors.black
                     ),
                     height: 100,
                     width: double.infinity,
                     child: Align(
                       alignment: Alignment.center,
                       child: Text("More Options", style: drawerHeader,),
                     )
                 )
             ),
           ),


           Expanded(
             flex:5,
             child:  Padding(
               padding: EdgeInsets.symmetric(horizontal: 20),
               child:Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: <Widget>[
                   drawerNavItem("Save Meter Numbers", Icons.add_circle, Addons(), "Addons"),

                   drawerNavItem("Add frequently used amount", Icons.attach_money, "", ""),


                   drawerNavItemShare("Share App on WhatsApp", Icons.share,),

                   drawerNavItem("Logout", Icons.security, "", ""),

                Spacer(),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
//                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                print("rate 1");
                              },
                              child: Icon(Icons.star_border),
                            ),
                            GestureDetector(
                              onTap: (){
                                print("rate 2");
                              },
                              child: Icon(Icons.star_border),
                            ),
                            GestureDetector(
                              onTap: (){
                                print("rate 3");
                              },
                              child: Icon(Icons.star_border),
                            ),
                            GestureDetector(
                              onTap: (){
                                print("rate 4");
                              },
                              child: Icon(Icons.star_border),
                            ),
                            GestureDetector(
                              onTap: (){
                                print("rate 5");
                              },
                              child: Icon(Icons.star_border),
                            ),

                          ],
                        ),
                        Text("Rate this app", style: label,)
                      ],
                    ),
                  )


                 ],
               ),),
           ),
//            Spacer(),
//           Text("")
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          MtnOptions(analytics: widget.analytics, observer: widget.observer),
          MtnOptions(analytics: widget.analytics, observer: widget.observer)
        ],
      )
    );
  }

  drawerNavItem(String label, IconData icon, route, String routeName){
    return                 GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => route,
              settings: RouteSettings(name: '$routeName'),
            ),
          );
        },
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(icon),
            ),
            Text("$label"),
          ],
        )
    );
  }

  drawerNavItemShare(String label, IconData icon){
    return                 GestureDetector(
        onTap: (){
//          AdvancedShare.whatsapp(msg: "Download Kene Smart USSD from playstore and Apple store for your USSD experiences :)")
//              .then((response) {
////            handleResponse(response, appName: "Whatsapp");
//          });

        },
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(icon),
            ),
            Text("$label"),
          ],
        )
    );
  }


}
