import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kene/components/loader.dart';
import 'package:kene/pages/services.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



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


  // Needed variable for checking device version and displaying services or not
  String minimumSupportedVersion = '';
  String packageInfo = "";

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


    // Get the supported minimum version from database
    Firestore.instance.collection("settings").getDocuments().then((f) {
      setState(() {
        minimumSupportedVersion =
            f.documents[0].data['minimum_supported_version'];
      });


      //  Get the package/build/version number of the device on load
      PackageInfo.fromPlatform().then((f) {
        setState(() {
          packageInfo = f.version.toString() + "+" + f.buildNumber.toString();
        });
      });
    });

  }


  // Check if device is supported to display services
  // Update the boolean to handle the different cases of supported devices and unsupported
  isOldVersion() {
    double phoneVersion =
        double.parse(packageInfo.split("+")[0].split(".").join());
    double phoneBuild = double.parse(packageInfo.split("+")[1]);

    double minVersion =
        double.parse(minimumSupportedVersion.split("+")[0].split(".").join());
    double minBuild = double.parse(minimumSupportedVersion.split("+")[1]);

    if (phoneVersion < minVersion || (phoneVersion == minVersion && phoneBuild < minBuild)) {
      return true;
    }
   

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: MediaQuery.of(context).size.height * 0.72,
                      decoration: BoxDecoration(
                          color: Color(0xffE3E1E1),
                          borderRadius: BorderRadius.circular(40)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: StreamBuilder(
                          stream:
                          Firestore.instance.collection("services").snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || packageInfo == "")
                              return Center(
                                child: NLoader(),
                              );

                            snapshot.data.documents.sort(
                                    (DocumentSnapshot a, DocumentSnapshot b) =>
                                    getServiceOrderNo(a)
                                        .compareTo(getServiceOrderNo(b)));
                            return !isOldVersion()
                                ? ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                return snapshot.data.documents[index]
                                ['isActive']
                                    ?
                                CarriersItem(
                                  carrierID: snapshot.data.documents[index].documentID,
                                  label: snapshot.data.documents[index]['label'],
                                  analytics: widget.analytics,
                                  color: snapshot.data.documents[index]['primaryColor'],
                                  icon: snapshot.data.documents[index]['icon'],)
                                    : Container();
                              },
                            )
                                : Container(
                              child: StreamBuilder(
                                  stream: Firestore.instance.collection("settings").where("label", isEqualTo:"versioning" ).snapshots(),
                                  builder: (context, snapshot) {
                                    return Center(
                                      child: Text(
                                        "${snapshot.data.documents[0]['update_message']}",
                                        textAlign: TextAlign.center,
                                      ),
                                    );
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

  int getServiceOrderNo(x) {
    return x['orderNo'];
  }

//  buildServiceListItem("Mtn", Color(0xffE0C537), "00001"),
//  buildServiceListItem("Airtel", Color(0xffED3737), "00002"),

}



/// A class for carrierItems
class CarriersItem extends StatefulWidget{
  final label;
  final color;
  final carrierID;
  final icon;
  final analytics;

  CarriersItem({this.label, this.analytics, this.icon, this.carrierID, this.color});

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
                    navigateTo: Services(
                      carrierId: widget.carrierID,
                      primaryColor: Color(widget.color),
                      carrierTitle: widget.label,
                      analytics: widget.analytics,
                    ))).then((d){
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
