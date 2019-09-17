import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kene/pages/services.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:package_info/package_info.dart';

class Carriers extends StatefulWidget {
  final analytics;
  Carriers({this.analytics});

  @override
  State<StatefulWidget> createState() {
    return _CarriersState();
  }
}

class _CarriersState extends State<Carriers> {
  String minimumSupportedVersion = '';
  String packageInfo = "";
//  bool hasOldVersion = false;

  @override
  void initState() {
    super.initState();

    Firestore.instance.collection("settings").getDocuments().then((f) {
      setState(() {
        minimumSupportedVersion =
            f.documents[0].data['minimum_supported_version'];
      });

      PackageInfo.fromPlatform().then((f) {
        // for getting the package/build/version number on load
        setState(() {
          packageInfo = f.version.toString() + "+" + f.buildNumber.toString();
        });
      });
    });
  }

  isOldVersion() {
    double phoneVersion =
        double.parse(packageInfo.split("+")[0].split(".").join());
    double phoneBuild = double.parse(packageInfo.split("+")[1]);

    double minVersion =
        double.parse(minimumSupportedVersion.split("+")[0].split(".").join());
    double minBuild = double.parse(minimumSupportedVersion.split("+")[1]);

    if (phoneVersion < minVersion || phoneBuild < minBuild) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40
                      // MediaQuery.of(context).size.height * 0.14,
                      ),
                  Container(
                      padding: EdgeInsets.only(right: 15),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "Nokanda",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 20
                      //  MediaQuery.of(context).size.height * 0.05,
                      ),
                  Text(
                    "Choose a service below",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.06,
                  // ),
                ],
              ),
            ),
            Positioned(
              top: 130,
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
                            child: Text("Loading ..."),
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
                                      ? buildServiceListItem(
                                          "${snapshot.data.documents[index]['label']}",
                                          snapshot.data.documents[index]
                                              ['primaryColor'],
                                          snapshot
                                              .data.documents[index].documentID,
                                          "${snapshot.data.documents[index]['icon']}")
                                      : Container();
//                              Text("${snapshot.data.documents[index].documentID}");
                                },
                              )
                            : Container(
                                child: Center(
                                  child: Text(
                                    "Sorry you have a very old version which is no longer supported. Please update on the app store to Contiune",
                                    textAlign: TextAlign.center,
                                  ),
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
      ),
    );
  }

  int getServiceOrderNo(x) {
    return x['orderNo'];
  }

//  buildServiceListItem("Mtn", Color(0xffE0C537), "00001"),
//  buildServiceListItem("Airtel", Color(0xffED3737), "00002"),

  GestureDetector buildServiceListItem(
      String label, var color, String carrierID, String icon) {
    print(icon);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CustomPageRoute(
                navigateTo: Services(
              carrierId: carrierID,
              primaryColor: Color(color),
              carrierTitle: label,
              analytics: widget.analytics,
            )));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        height: 60,
        decoration: BoxDecoration(
            // border: Border.all(color: mainColor),
            color: Colors.white,
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
                      imageUrl: icon,
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
                    child: Text(
                      label,
                      style: TextStyle(
                          color: Colors.black54,
                          // mainColor,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
