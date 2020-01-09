import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kene/components/CustomFloatingButton.dart';
import 'package:kene/components/bottom_navigation.dart';
import 'package:kene/components/loader.dart';
import 'package:kene/pages/services.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_flutter/qr_flutter.dart';


class Carriers extends StatefulWidget {

  /// Receives analytics to send events
  final analytics;

  Carriers({this.analytics});

  @override
  State<StatefulWidget> createState() {
    return _CarriersState();
  }
}

class _CarriersState extends State<Carriers> {


  bool isOlderVersion;
  var _qrScan;

  var collectionsCache = [];

  final FirebaseMessaging _fireBaseMessaging = FirebaseMessaging();
  ScrollController _scrollController;

  String locale = "en";

  Firestore firestoreInstance;


  // Data to hold the pages string from fireBase for translations
  var pageData = {};

  listener(){
    if(_scrollController.offset >= 45){
      _scrollController.jumpTo(45);
    }
  }



  @override
  void initState() {
    super.initState();

    var appBloc;

    firestoreInstance = Firestore.instance;

    appBloc = BlocProvider.of(context);

    appBloc.localeOut.listen((data) {
      setState(() {
        locale = data != null ? data : locale;
      });
    });


    getPageData("carriers_page").then((data){
      setState(() {
        pageData = data;
      });
    });


//    fetchAllServices().then((d){
//      for(var item in collectionsCache){
//        print("item is: " + item['label']);
//      }
//    });


    FirebaseAuth.instance.currentUser().then((f){ // Set the logged in phone number as qrCode data
      if(f != null){
        setState(() {
          _qrScan = QrImage(
            data: f.phoneNumber.toString(),
            version: QrVersions.auto,
            size: 200.0,
          );
        });
      }
    });
    // Scroll controller for listView
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(listener);

    print(" carriers analytics is==========>>>>");
    print(widget.analytics);

    // Send analytics on page load/initialize
    sendAnalytics(widget.analytics, "CariersPage_Open", null);


    // Callbacks for fireBase messaging for various events
    _fireBaseMessaging.requestNotificationPermissions();
    _fireBaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async{
      print("on message: $message");
      return ;
    },

    onResume: (Map<String, dynamic> message) async{
      print("on resume: $message");
      return ;
    },

      onLaunch: (Map<String, dynamic> message) async{
        print("on launch: $message");
        return ;
      },

    );

    _fireBaseMessaging.getToken().then((token){
      print("notificaion token is $token");
    });


    // Set is olderVersion
    isOldVersion().then((state){
      setState(() {
        isOlderVersion = state;
      });
    });

    // Update version on firebase
    updateVersion();


  }




  fetchAllServices() async{
    String rootURL = "services";
    var secondLevel = await Firestore.instance.collection(rootURL).getDocuments();

    collectionsCache += secondLevel.documents;
    for (var child in secondLevel.documents){
      await recurseLoad(rootURL + "/"+child.documentID+"/services");
    }

    print(" ----->> the length of the cache is");
    print(collectionsCache.length);

  }

  recurseLoad(String url) async{
    var root = await Firestore.instance.collection(url).getDocuments();
    collectionsCache += root.documents;

    if(root.documents.length < 1){
      return;
    }

    else {
      for (var child in root.documents) {
        if (child['hasChildren'] != null && child['hasChildren']) {
          url += "/" + child.documentID + "/children";
          print(child['label']);
          print(url);
          recurseLoad(url);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CustomFloatingButton(pageData: pageData, analytics: widget.analytics, locale: locale,),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: CustomBottomNavigation(isCurrentPage: true,),
      body:
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, bool isScrolled){
            return <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.175,
                elevation: 14,
                pinned: true,
                floating: true,
                centerTitle: true,
                forceElevated: isScrolled,
                actions: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          CustomPageRoute(navigateTo: Settings(analytics: widget.analytics,)));
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
                title: AutoSizeText(
                  "Nokanda",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: buttonTextFamily,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 2,
                ),
                backgroundColor: mainColor,
                leading: Text(""),
                flexibleSpace: Container(
                  decoration: BoxDecoration(

                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(
//                          "Choose a service"
                          getTextFromPageData(pageData, "sub_header", locale),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),

              )
            ];
          }, body: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[

                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.175,
                  decoration: BoxDecoration(
                      color: mainColor,

                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                    ],
                  ),
                ),

                Positioned(
                  top: 0,
                  // MediaQuery.of(context).size.height * 0.35,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:20.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.72,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          
                          // Color(0xffE3E1E1),
                          borderRadius: BorderRadius.circular(40)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: StreamBuilder(
                          stream:
                          firestoreInstance.collection("services").snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || isOlderVersion == null)
                              return Center(
                                child: NLoader(),
                              );

                            snapshot.data.documents.sort(
                                    (DocumentSnapshot a, DocumentSnapshot b) =>
                                    getServiceOrderNo(a)
                                        .compareTo(getServiceOrderNo(b)));

                            return !isOlderVersion
                                ?
                                GridView.count(
                                  
                                  shrinkWrap: true,
                                  children: getActiveCarriers(snapshot.data.documents), 
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                )
                                : Container(
                              child: StreamBuilder(
                                  stream: firestoreInstance.collection("settings").where("label", isEqualTo:"versioning" ).snapshots(),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "${snapshot.data.documents[0]['update_message']}",
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 20,),
                                          Platform.isIOS ?
                                              CupertinoButton(

                                                  child: Text("Click to update"), onPressed: (){
                                                upDateButtonAction();

                                              })
                                              :

                                          RaisedButton(
                                            color: Colors.orangeAccent,
                                            onPressed: (){
                                              upDateButtonAction();
                                            },
                                            child: Text("Click to update", style: TextStyle(
                                              color: Colors.white
                                            ),),
                                          )
                                        ],
                                      )
                                    ):

                                    NLoader();
                                  }
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),)

    );
  }

getActiveCarriers(list){
  List<Widget> tmp = [];

  // tmp.add(Text("ni"));

  
  for(int i = 0; i < list.length; i++){
  if(list[i]['isActive']){
    tmp.add(

      GestureDetector(
        onTap: (){
          
         Navigator.push(context,  CustomPageRoute(
                    navigateTo: Services(
                      carrierId:list[i].documentID,
                      primaryColor: mainColor,
                      carrierTitle: list[i]['name_map'] != null && list[i]['name_map'][locale] == null ? list[i]['name_map']["en"]

                          : list[i]['name_map'] != null && list[i]['name_map'][locale] != null

                          ?list[i]['name_map'][locale]  :  list[i]['label'],
                      analytics: widget.analytics,
                    )
                ));
        },
        child:
      Container(
        // height: 200,
        padding: EdgeInsets.symmetric(horizontal:10),
        decoration: BoxDecoration(
          color: Color(0xfff6f7f9),
          // border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          SizedBox(
                    height: 60,
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: list[i]['icon'],
                        placeholder: (context, url) => new Icon(
                          Icons.album,
                          size: 40,
                        ),
                        errorWidget: (context, url, error) => new Icon(
                          Icons.album,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
          Text( list[i]['name_map'] != null && list[i]['name_map'][locale] == null ? list[i]['name_map']["en"]

              : list[i]['name_map'] != null && list[i]['name_map'][locale] != null

              ?list[i]['name_map'][locale]  :  list[i]['label'], textAlign: TextAlign.center, style: TextStyle(
              fontWeight: FontWeight.w600,
          ),)
        ],),
      ))
      )
    );
  }
  }

//  tmp.add(
//    GestureDetector(
//        onTap: () async{
//          var uid = await getUserID();
//          Navigator.push(context,  CustomPageRoute(
//                     navigateTo: NShortcuts(
//                       userID:uid,
//                       primaryColor: Colors.orangeAccent,
//                       carrierTitle: getTextFromPageData(pageData, "shortcuts", locale),
//                       analytics: widget.analytics,
//                     )
//                 ));
//        },
//        child:
//      Container(
//        // height: 200,
//        padding: EdgeInsets.symmetric(horizontal:10),
//        decoration: BoxDecoration(
//          color: Color(0xfff6f7f9),
//          // border: Border.all(color: Colors.blue),
//          borderRadius: BorderRadius.circular(8),
//        ),
//        child: Center(child:Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//          SizedBox(
//                    height: 60,
//                    width: 60,
//                    child: ClipRRect(
//                      borderRadius: BorderRadius.circular(10),
//                      child: CachedNetworkImage(
//                        fit: BoxFit.cover,
//                        imageUrl: "",
//                        placeholder: (context, url) => new Icon(
//                          Icons.favorite,
//                          size: 60,
//                          color: Colors.orangeAccent,
//                        ),
//                        errorWidget: (context, url, error) => new Icon(
//                          Icons.favorite,
//                          size: 60,
//                          color: Colors.orangeAccent,
//                        ),
//                      ),
//                    ),
//                  ),
//                  SizedBox(
//                    height: 10,
//                  ),
//          Text(getTextFromPageData(pageData, "shortcuts", locale), textAlign: TextAlign.center, style: TextStyle(
//              fontWeight: FontWeight.w600
//          ),)
//        ],),
//      ))
//      )
//  );

  return tmp;
}


  int getServiceOrderNo(x) {
    return x['orderNo'];
  }

//  buildServiceListItem("Mtn", Color(0xffE0C537), "00001"),
//  buildServiceListItem("Airtel", Color(0xffED3737), "00002"),

}

