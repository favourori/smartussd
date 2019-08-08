import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kene/control.dart';
import 'package:kene/pages/save_accounts.dart';
import 'package:kene/widgets/custom_nav.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                color: Color(0xffC89191),
                // borderRadius: BorderRadius.only(
                // bottomLeft: Radius.circular(40),
                // bottomRight: Radius.circular(40))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Settings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          
                          fontWeight: FontWeight.w900,
                          fontSize: 36),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: ListView(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                           Navigator.push(context, CustomPageRoute(
                              navigateTo: SaveAccount()
                            ));
                        },
                        child: ListTile(
                          leading: Icon(Icons.add_circle),
                          title: Text("Save accounts"),
                          subtitle: Text(
                            "Save your meter numbers etc",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text("Share on WhatsApp"),
                          subtitle: Text(
                            "Share app with friends",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut().then((_){
                            Navigator.pushReplacement(context, CustomPageRoute(
                              navigateTo: Control()
                            ));
                          });
                        },
                        child: ListTile(
                          leading: Icon(Icons.security),
                          title: Text("Logout"),
                          // subtitle: Text("Save your meter numbers etc", style: TextStyle(
                          //   fontSize: 13
                          // ),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
