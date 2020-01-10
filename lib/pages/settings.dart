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
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:package_info/package_info.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';



class Settings extends StatefulWidget {

  final analytics;

  Settings({
    this.analytics
});
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  PackageInfo packageInfo;
  List languageList = [];

  var pageData = {};
  String locale = "en";


  @override
  void initState() {
    super.initState();

    var appBloc;

    appBloc = BlocProvider.of(context);

    appBloc.localeOut.listen((data) {
      setState(() {
        locale = data != null ? data : locale;
      });
    });


    getPageData("settings_page").then((data){
      setState(() {
        pageData = data;
      });
    });


    // Get language codes from database here
    Firestore.instance.collection("language_codes").getDocuments().then((data){
      setState(() {
        languageList = data.documents;
      });
    });


    // For getting the package/build/version number on load
    PackageInfo.fromPlatform().then((f) {
      setState(() {
        packageInfo = f;
      });
    });

    // Send analytics on page load/initialize
    sendAnalytics(widget.analytics, "SettingsPage_Open", null);

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: pageData != {} ? Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height*0.3,
                color: mainColor,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.1,
                    ),

                    AutoSizeText(getTextFromPageData(pageData, "menu", locale), style:TextStyle(
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
                  decoration: BoxDecoration(
                    boxShadow: [
//                      BoxShadow(
//                        offset: Offset(1, 1),
//                        blurRadius: 1.5,
//                        color: Colors.grey.withOpacity(0.8)
//                      )
                    ]
                  ),
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.68,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              CustomPageRoute(navigateTo: SaveAccount(analytics: widget.analytics,)));
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.add_circle,
                            color: Colors.orangeAccent,
                          ),
                          title: Text(getTextFromPageData(pageData, "save_accounts", locale)),
                          subtitle: Text(
                            getTextFromPageData(pageData, "save_accounts_desc", locale),
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
                              title: Text(getTextFromPageData(pageData, "share_nokanda", locale)),
                              subtitle: Text(
                                getTextFromPageData(pageData, "share_nokanda_desc", locale),
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
                          title: Text(getTextFromPageData(pageData, "change_language", locale)),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              CustomPageRoute(navigateTo: About(analytics: widget.analytics)));
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.info,
                            color: Colors.orangeAccent,
                          ),
                          title: Text(getTextFromPageData(pageData, "about_nokanda", locale)),
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
                          title: Text(getTextFromPageData(pageData, "faq", locale)),
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
                          title: Text(getTextFromPageData(pageData, "contact_us", locale)),
                          // subtitle: Text("Save your meter numbers etc", style: TextStyle(
                          //   fontSize: 13
                          // ),),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut().then((_) {
//                            Navigator.pushReplacement(context,
//                                CustomPageRoute(navigateTo: Control()));


                            Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(pageBuilder: (BuildContext context, Animation animation,
                                    Animation secondaryAnimation) {
                                  return Control();
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
                          });
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.security,
                            color: Colors.orangeAccent,
                          ),
                          title: Text(getTextFromPageData(pageData, "logout", locale)),
                          // subtitle: Text("Save your meter numbers etc", style: TextStyle(
                          //   fontSize: 13
                          // ),),
                        ),
                      ),
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
          ): Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
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
            CupertinoButton(child: Text(getTextFromPageData(pageData, "close", locale)), onPressed: (){
              Navigator.pop(context);
            })
          ],
        ))
        :
    showDialog(context: context, builder: (context)=> AlertDialog(
      title: Text(getTextFromPageData(pageData, "select_language", locale), style: TextStyle(
          color: Colors.orange
      ),),

      content: ChooseLanguage(languageList: languageList,),
    ));
  }

}
