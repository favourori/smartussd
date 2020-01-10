import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:kene/widgets/custom_nav.dart';

class ShortcutAdd extends StatefulWidget {
  final userID;
  final analytics;

  ShortcutAdd({this.userID, this.analytics});

  @override
  _ShortcutAddState createState() => _ShortcutAddState();
}

class _ShortcutAddState extends State<ShortcutAdd> {
  String carrierName = "Select";
  List<DropdownMenuItem> list = [];
  List<Widget> subservices = [];
  String currentId = "";
  bool isLoading = false;

  // Data to hold the pages string from fireBase for translations
  var pageData = {};
  String locale = "en";

  ScrollController _scrollController;
  ScrollController _listViewController = new ScrollController();

  listener() {
    if (_scrollController.offset >= 45) {
      _scrollController.jumpTo(45);
    }
  }

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


    getPageData("shortcuts").then((data){
      setState(() {
        pageData = data;
      });
    });


    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(listener);

    Firestore.instance
        .collection("/services")
        .where("isActive", isEqualTo: true)
        .getDocuments()
        .then((data) {
      List<DropdownMenuItem> tmp = [];
      tmp.add(DropdownMenuItem(
        child: Text("Select"),
        value: "Select",
      ));
      for (var item in data.documents) {
        tmp.add(DropdownMenuItem(
          child: Text("${item['label']}"),
          value: "${item['label']}",
        ));
      }

      setState(() {
        list = tmp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, bool isScrolled) {
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
                      Navigator.push(
                          context,
                          CustomPageRoute(
                              navigateTo: Settings(
                            analytics: widget.analytics,
                          )));
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
                backgroundColor: mainColor,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          getTextFromPageData(pageData, "sub_title", locale),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ];
          },
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.175,
                decoration: BoxDecoration(
                    color: mainColor,

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[],
                ),
              ),
              Positioned(
//                  top: 0.0,
//                  left: 0.0,
//                  bottom: 0.0,
//                  right: 0.0,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 0),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          // MediaQuery.of(context).size.width - 40,
                          height: MediaQuery.of(context).size.height * 0.9,
                          decoration: BoxDecoration(
                              color: Color(0xfff6f7f9),
                              borderRadius: BorderRadius.circular(40)),
                          child:
                          Container(
                            child:
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 40,),

                                Expanded(
                                  flex: 1,
                                  child: !isLoading ?
                                  DropdownButton(value:carrierName, items: list, onChanged: (v){
                                    setState(() {
                                      carrierName = v;
                                    });

                                    getServices();
                                  }):

                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        CircularProgressIndicator(backgroundColor: Colors.black87, strokeWidth: 4,),
                                        SizedBox(width: 15,),
                                        Text("Loading"),
                                      ],
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: ListView(
                                    controller: _listViewController,
                                  children: subservices,
                                ), flex: 8,)
                              ],
                            ),
                          ),



                      )))
            ]),
          )


          ),
    );
  }

  Future<String> getCarrierID(String label) async {
    var data = await Firestore.instance
        .collection("/services")
        .where("label", isEqualTo: label)
        .getDocuments();

    return data.documents[0].documentID;
  }

  getServices() async {
    String id = await getCarrierID(carrierName);

    print("id is =============> $id");


    getSubServices(id, "fetch_carier_children");
  }

  getSubServices(String id, String intent) async {
    print("called");
    String url = "";

    if (intent == "fetch_carier_children") {
      url = "/services/" + id + "/services";
    } else {
      url = id;
    }

    setState(() {
      currentId = url;
    });

    print(url);
    setState(() {
      isLoading = true;
    });
    var res = await Firestore.instance
        .collection(url)
        .where("isActive", isEqualTo: true)
        .getDocuments();
    String shortcutUrl = "shortcuts/" + widget.userID + "/shortcuts";
    var userCurrentShortcuts =
        await Firestore.instance.collection(shortcutUrl).getDocuments();

    print("reached here");

    bool skip = false;

    List<Widget> temp = [];
    for (var item in res.documents) {
      skip = false;

      String newName = carrierName + item['name'];
      print(newName);
      for (var current in userCurrentShortcuts.documents) {
        String oldName = current['carrier'] + current['name'];

        if (oldName == newName) {
          skip = true;
          break;
        }
      }

      if (!skip) {
        temp.add(ListTile(
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text(
                item['name'].substring(0, 2),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              if (item['hasChildren'] != null && item['hasChildren']) {
                currentId += "/" + item.documentID + "/children";
                print(currentId);
                getSubServices(currentId, "fetch_services_children");
              }
            },
            child: Text(
              item['name'], style: TextStyle(fontFamily: regularTextFamily),
            ),
          ),
          trailing: item['hasChildren'] != null && item['hasChildren']
              ? null
              : IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    var data = {
                      "backgroundColor": item[''],
                      "icon": item['icon'],
                      "name": item['name'],
                      "label": item['label'],
                      "needsContact": item['needsContact'],
                      "needsRecipient": item['needsRecipient'],
                      "requiresInput": item['requiresInput'],
                      "code": item['code'],
                      "recipientLabel": item['recipientLabel'],
                      "canSaveLabels": item['canSaveLabels'],
                      "needsAmount": item['needsAmount'],
                      "requiresCamera": item['requiresCamera'],
                      "serviceDescription": item['serviceDescription'],
                      "hasChildren": item['hasChildren'],
                      "parentID": item[''],
                      "needsScan": item['needsScan'],
                      "carrier": carrierName,
                    };

                    var favouriteData = data;
                    favouriteData['backgroundColor'] = 1245664;
                    print(favouriteData);
                    addToShortcut(data);
                    getSubServices(currentId, "fetch_services_children");
                  }),
        ));
      }
    }

    setState(() {
      isLoading = false;
      subservices = temp;
    });
  }
}
