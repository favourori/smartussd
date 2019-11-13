import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kene/components/choose_language.dart';
import 'package:kene/control.dart';
import 'package:kene/pages/about.dart';
import 'package:kene/pages/faq.dart';
import 'package:kene/pages/save_accounts.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:package_info/package_info.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';



class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  PackageInfo packageInfo;
  List languageList = [];


  @override
  void initState() {
    super.initState();

    // Get languages here and pass to languages widgets
    Firestore.instance.collection("language_codes").getDocuments().then((data){
      setState(() {
        languageList = data.documents;
      });
    });

    PackageInfo.fromPlatform().then((f) {
      // For getting the package/build/version number on load
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

                    AutoSizeText("Menu", style:TextStyle(
                      color:Colors.white,
                      fontSize:28,
                      
                    ),
                    
                    maxLines: 2,)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3.0, top: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.68,
                  child: ListView(
                    shrinkWrap: true,
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
                      StreamBuilder(
                        stream: Firestore.instance.collection("settings").snapshots(),
                        builder: (context, snapshot){
                          return GestureDetector(
                            onTap: () {


                              share();

                            },
                            child: ListTile(
                              leading: Icon(
                                Icons.share,
                                color: Colors.orangeAccent,
                              ),
                              title: Text("Share Nokanda"),
                              subtitle: Text(
                                "Share app with friends",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),


                      GestureDetector(
                        onTap: () {
                          reactiveDialog();
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.language,
                            color: Colors.orangeAccent,
                          ),
                          title: Text("Change Language"),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              CustomPageRoute(navigateTo: About()));
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.info,
                            color: Colors.orangeAccent,
                          ),
                          title: Text("About Nokanda"),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              CustomPageRoute(navigateTo: FAQ()));
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.question_answer,
                            color: Colors.orangeAccent,
                          ),
                          title: Text("FAQ"),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          _sendEmail("support@hexakomb.com");

                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.email,
                            color: Colors.orangeAccent,
                          ),
                          title: Text("Contact us"),
                          // subtitle: Text("Save your meter numbers etc", style: TextStyle(
                          //   fontSize: 13
                          // ),),
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
//                      SizedBox(
//                        height: MediaQuery.of(context).size.height * 0.2,
//                      ),
//                      Expanded(flex: 1,child: Container(),),
                     Align(
                       alignment: Alignment.bottomCenter,
                       child:  Padding(
                           padding: EdgeInsets.only(left: 20),
                           child: Text(
                             packageInfo != null
                                 ? "Version: ${packageInfo.version.toString() + " Build: " + packageInfo.buildNumber}"
                                 : "",
                             style: TextStyle(color: Colors.grey),
                           ),
                     )
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  _sendEmail(String email) async {
    String url = 'mailto:$email?subject=Contact%20message%20from%20Nokanda%20App';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  reactiveDialog(){
    Platform.isIOS ?
        showCupertinoDialog(context: context, builder: (context) => CupertinoAlertDialog(
          content: ChooseLanguage(languageList: languageList,),
          actions: <Widget>[
            CupertinoButton(child: Text("Close"), onPressed: (){
              Navigator.pop(context);
            })
          ],
        ))
        :
    showDialog(context: context, builder: (context)=> AlertDialog(
      title: Text("Select Language", style: TextStyle(
          color: Colors.orange
      ),),

      content: ChooseLanguage(languageList: languageList,),
    ));
  }

}

//"Android : \nhttps://play.google.com/store/apps/details?id=com.hexakomb.nokanda \niOS: \nhttps://bit.ly/nokandaios"