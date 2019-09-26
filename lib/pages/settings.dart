import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kene/control.dart';
import 'package:kene/pages/save_accounts.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:advanced_share/advanced_share.dart' show AdvancedShare;
import 'package:package_info/package_info.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  PackageInfo packageInfo;
  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((f) {
      // for getting the package/build/version number on load
      setState(() {
        packageInfo = f;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height*0.3,
                color: Colors.orange,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.1,
                    ),

                    Text("Settings", style:TextStyle(
                      color:Colors.white,
                      fontSize:28
                    ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3.0, top: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.68,
                  child: ListView(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              CustomPageRoute(navigateTo: SaveAccount()));
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.add_circle,
                            color: Colors.orangeAccent,
                          ),
                          title: Text("Save accounts"),
                          subtitle: Text(
                            "Save your meter numbers etc",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AdvancedShare.whatsapp(
                            msg:
                                "Hi!! \nHave you heard of the new Nokanda app ? \nIt saves you alot of time using mobile money and USSD Services. \nTry it out ) \n https://play.google.com/store/apps/details?id=com.hexakomb.nokanda",
                            url: "",
                          ).then((response) {
//                            handleResponse(response, appName: "Whatsapp");
                            print("Shared on whatsapp");
                          });
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.share,
                            color: Colors.orangeAccent,
                          ),
                          title: Text("Share on WhatsApp"),
                          subtitle: Text(
                            "Share app with friends",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut().then((_) {
                            Navigator.pushReplacement(context,
                                CustomPageRoute(navigateTo: Control()));
                          });
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.security,
                            color: Colors.orangeAccent,
                          ),
                          title: Text("Logout"),
                          // subtitle: Text("Save your meter numbers etc", style: TextStyle(
                          //   fontSize: 13
                          // ),),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(
                          packageInfo != null
                              ? "Version: ${packageInfo.version.toString() + "+" + packageInfo.buildNumber}"
                              : "",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
