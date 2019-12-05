import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kene/components/loader.dart';
import 'package:kene/pages/receive.dart';
import 'package:kene/pages/services.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/functions.dart';
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

  final FirebaseMessaging _fireBaseMessaging = FirebaseMessaging();
  ScrollController _scrollController;


  listener(){
    if(_scrollController.offset >= 45){
      _scrollController.jumpTo(45);
    }
  }




  @override
  void initState() {
    super.initState();

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xfff6f7f9),
        child: Icon(Icons.favorite, size: 30, color: Colors.orangeAccent,),
        onPressed: (){},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.orangeAccent,
        elevation: 14,
        child: Container(
          height: 50,
          child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
            child: GestureDetector(
              onTap: (){},
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.home, color: Colors.white,),
                // Text("Home", style: TextStyle(
                //   color: Colors.white, fontWeight: FontWeight.bold
                // ),)
              ],
            ),
            )),


             Expanded(
              flex: 2,
            child: GestureDetector(
              onTap: (){},
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.more_vert, color: Colors.white,),
                // Text("More", style: TextStyle(
                //   color: Colors.white, fontWeight: FontWeight.bold
                // ),)
              ],
            ),
            )),

            // Expanded(
            //   flex: 2,
            //   child: Container(),
            // )

          ],
        ),
        ),      ),
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
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 2,
                ),
                backgroundColor: Colors.orange,
                leading: Text(""),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Choose a service",
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
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40))),
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
                          Firestore.instance.collection("services").snapshots(),
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
                              //   Column(
                              // children: <Widget>[

                                GridView.count(
                                  
                                  shrinkWrap: true,
                                  children: getActiveCarriers(snapshot.data.documents), 
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                )
                                // ListView.builder(
                                //   shrinkWrap: true,
                                //   itemCount: snapshot.data.documents.length,
                                //   itemBuilder: (context, index) {
                                //     return snapshot.data.documents[index]
                                //     ['isActive']
                                //         ?
                                //     CarriersItem(
                                //       isReceiveButton: false,
                                //       carrierID: snapshot.data.documents[index].documentID,
                                //       label: snapshot.data.documents[index]['label'],
                                //       analytics: widget.analytics,
                                //       color: snapshot.data.documents[index]['primaryColor'],
                                //       icon: snapshot.data.documents[index]['icon'],
                                //       qrScan: _qrScan,
                                //     )
                                //         : Container();
                                //   },
                                // ),

                                // _qrScan != null ?

                                //     GestureDetector(
                                //       onTap: (){},
                                //       child: CarriersItem(
                                //         isReceiveButton: true,
                                //         icon: "",
                                //         label: "Receive Payment",
                                //         qrScan: _qrScan,
                                //       ),
                                //     )
                                //     :
                                //     Container()

                            //   ],
                            // )
                                : Container(
                              child: StreamBuilder(
                                  stream: Firestore.instance.collection("settings").where("label", isEqualTo:"versioning" ).snapshots(),
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
          
          print("tappeddd");
         Navigator.push(context,  CustomPageRoute(
                    navigateTo: Services(
                      carrierId:list[i].documentID,
                      primaryColor: Color(list[i]['primaryColor']),
                      carrierTitle: list[i]['label'],
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
          Text("${list[i]['label']}", textAlign: TextAlign.center, style: TextStyle(
              fontWeight: FontWeight.w600
          ),)
        ],),
      ))
      )
    );
  }
  }

  tmp.add(
    GestureDetector(
        onTap: (){
          
        //   print("tappeddd");
        //  Navigator.push(context,  CustomPageRoute(
        //             navigateTo: Services(
        //               carrierId:list[i].documentID,
        //               primaryColor: Color(list[i]['primaryColor']),
        //               carrierTitle: list[i]['label'],
        //               analytics: widget.analytics,
        //             )
        //         ));
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
                        imageUrl: "",
                        placeholder: (context, url) => new Icon(
                          Icons.favorite,
                          size: 60,
                          color: Colors.orangeAccent,
                        ),
                        errorWidget: (context, url, error) => new Icon(
                          Icons.favorite,
                          size: 60,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
          Text("Favourites", textAlign: TextAlign.center, style: TextStyle(
              fontWeight: FontWeight.w600
          ),)
        ],),
      ))
      )
  );

  return tmp;
}


  int getServiceOrderNo(x) {
    return x['orderNo'];
  }

//  buildServiceListItem("Mtn", Color(0xffE0C537), "00001"),
//  buildServiceListItem("Airtel", Color(0xffED3737), "00002"),

}



/// A class for carrierItems
class CarriersItem extends StatefulWidget{
  final isReceiveButton;
  final label;
  final color;
  final carrierID;
  final icon;
  final analytics;
  final qrScan;

  CarriersItem({this.label, this.analytics, this.qrScan, this.icon, this.carrierID, this.isReceiveButton, this.color});

  @override
  _CarriersItemState createState() => _CarriersItemState();
}

class _CarriersItemState extends State<CarriersItem> {

  bool isBtnClicked = false;

  build(context){
    return
      GestureDetector(
        onTap: () {
          setState(() {
            isBtnClicked  = true;
          });
          Future.delayed(Duration(milliseconds: 50)).then((d){
            Navigator.push(
                context,
                CustomPageRoute(
                    navigateTo: !widget.isReceiveButton ? Services(
                      carrierId: widget.carrierID,
                      primaryColor: Color(widget.color),
                      carrierTitle: widget.label,
                      analytics: widget.analytics,
                    ):
                    ReceivePage(qrImage: widget.qrScan,)
                )

            ).then((d){
                      setState(() {
                        isBtnClicked = false;
                      });
            });
          });
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          height: 60,
          decoration: BoxDecoration(
            // border: Border.all(color: mainColor),
              color: isBtnClicked ?  Colors.black12  :  Colors.white,
              borderRadius: BorderRadius.circular(40)),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.icon,
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
                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            Text(
                              widget.label,
                              style: TextStyle(
                              color: Colors.black54,
                              // mainColor,
                              fontWeight: FontWeight.w900),
                            ),
                          ],
                        )
                    ),
                  )
                ],
              )),
        ),
      );
    }
}
