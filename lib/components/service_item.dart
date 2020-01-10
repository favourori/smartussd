import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:kene/utils/functions.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ServiceItem extends StatefulWidget {
  final backgroundColor;
  final icon;
  final name;
  final label;
  final needsContact;
  final needsRecipient;
  final requiresInput;
  final codeToSend;
  final recipientLabel;
  final canSaveLabels;
  final needsAmount;
  final requiresCamera;
  final serviceDescription;
  final hasChildren;
  final parentID;
  final nameMap;
  final primaryColor;
  final needsScan;
  final carrierID;
  final favouritesMap;

  //
  // Operations done and sent to parent
  //

  final serviceActions;

  ServiceItem(
      {this.backgroundColor,
      this.carrierID,
      this.needsScan,
      this.primaryColor,
      this.label,
      this.nameMap,
      this.needsContact,
      this.requiresInput,
      this.needsRecipient,
      this.codeToSend,
      this.recipientLabel,
      this.canSaveLabels,
      this.needsAmount,
      this.requiresCamera,
      this.hasChildren,
      this.serviceDescription,
      this.parentID,
      this.icon,
      this.name,
      this.serviceActions,
      this.favouritesMap,
      });

  @override
  createState() => _ServiceItemState();
}

class _ServiceItemState extends State<ServiceItem> {
    final Widget nokandaIcon = SvgPicture.asset(
      "assets/images/hexagon.svg",
      height: 40,
      semanticsLabel: 'hexagon shape'
  );
  bool itemClicked = false;
  String locale = "en";
  var appBloc;

  Key dismissAbleKey = Key("dismissableKey");
  bool addedAsShortcut = false;

  Map<String, dynamic> data;


  Map<String, dynamic> _favouritesMap = {};


  @override
  void initState() {
    super.initState();

    // Get locale from stream
    appBloc = BlocProvider.of(context);

    // Get favorites list
    populateFavouriteMap();

    appBloc.localeOut.listen((data) {
      setState(() {
        locale = data != null ? data : locale;
      });
    });
  }

  @override
  build(context) {
    return GestureDetector(
      onTap: () {
        Future.delayed(Duration(milliseconds: 50)).then((f) {
          // delay for 300 milli secs before Navigating
          // Restore the boolean to revert the background color
          setState(() {
            itemClicked = false;
          });

          // sending name for parent to update to update header title
          String name = widget.requiresInput != null && widget.requiresInput
              ? widget.name
              : null;

          if (widget.hasChildren != null && widget.hasChildren) {
            /// UPDATE THE COLLECTION URL IF THERE'S CHILDREN FOR THE TREE TO REBUILD
            String newURL = "/" + widget.parentID + "/children";
            widget.serviceActions(newURL, 0, {
              "label": widget.label,
              "name": name,
              "name_map":widget.nameMap,
            }); //motive of 0, when it has children, and empty data
          }

          /// if does not require input, send code to parent to make the call
          else if (!widget.requiresInput) {
            widget.serviceActions(null, 1, {
              "code": widget.codeToSend,
              "label": widget.label,
              "name": name,
              "name_map":widget.nameMap,
            });
          } else {

            data = {
              "backgroundColor": widget.backgroundColor,
              "icon": widget.icon,
              "name": widget.name,
              "name_map":widget.nameMap,
              "label": widget.label,
              "needsContact": widget.needsContact,
              "needsRecipient": widget.needsRecipient,
              "requiresInput": widget.requiresInput,
              "code": widget.codeToSend,
              "recipientLabel": widget.recipientLabel,
              "canSaveLabels": widget.canSaveLabels,
              "needsAmount": widget.needsAmount,
              "requiresCamera": widget.requiresCamera,
              "serviceDescription": widget.serviceDescription,
              "hasChildren": widget.hasChildren,
              "parentID": widget.parentID,
              "needsScan": widget.needsScan,
              "carrier": widget.carrierID,
            };
            appBloc.serviceDataIn(data);

            /// call parent to open up action center
            widget
                .serviceActions(null, 2, {"label": widget.label, "name": name, "name_map":widget.nameMap});
          }
        });

        setState(() {
          itemClicked = true;
        });
      },
      child: (widget.hasChildren == null || !widget.hasChildren)
          ? Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 70,
                decoration: BoxDecoration(
                    color:
                        itemClicked ? Colors.black12 : widget.backgroundColor,
                    borderRadius: BorderRadius.circular(serviceItemBorderRadius)),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 10, bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        child: widget.icon == null || widget.icon == ""
                            ? nokandaIcon
                            :
                        showCachedImage(widget.icon)
                    
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 3),
                            child: widget.nameMap == null
                                ? Text(
                                    widget.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  )
                                : Text(
                                      widget.nameMap[locale] == null ? widget.nameMap["en"] :widget.nameMap[locale],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  )),
                      ),
                      (widget.hasChildren != null && widget.hasChildren) ||
                              (widget.requiresInput != null &&
                                  widget.requiresInput)
                          ? Padding(
                              padding: EdgeInsets.only(left: 3, right: 15),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: accentColor,
                              ),
                            )
                          : Text(""),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                IconSlideAction(
                    foregroundColor: Colors.red,
                    caption: itemInFav() || addedAsShortcut ?  "Added" :  'Add shortcut',

//              color: Colors.red,
                    icon: itemInFav() || addedAsShortcut ? FontAwesomeIcons.checkCircle : Icons.favorite,
                    onTap: () async{
                      print(addedAsShortcut);
                      data = {
                        "backgroundColor": widget.backgroundColor,
                        "icon": widget.icon,
                        "name": widget.name,
                        "label": widget.label,
                        "needsContact": widget.needsContact,
                        "needsRecipient": widget.needsRecipient,
                        "requiresInput": widget.requiresInput,
                        "code": widget.codeToSend,
                        "recipientLabel": widget.recipientLabel,
                        "canSaveLabels": widget.canSaveLabels,
                        "needsAmount": widget.needsAmount,
                        "requiresCamera": widget.requiresCamera,
                        "serviceDescription": widget.serviceDescription,
                        "hasChildren": widget.hasChildren,
                        "parentID": widget.parentID,
                        "needsScan": widget.needsScan,
                        "carrier": widget.carrierID,
                      };

                      var favouriteData = data;
                      favouriteData['backgroundColor'] = 1245664;
                      print(favouriteData);
                      if(!itemInFav() && !addedAsShortcut ){ // Add if item not in shortcuts
                        addToShortcut(data);
                        setState(() {
                          addedAsShortcut = true;
                        });
                      }
                    }),
//
              ],
              secondaryActions: <Widget>[
//
              ],
            )
          : Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 70,
              decoration: BoxDecoration(
                  // border: Border.all(color: widget.primaryColor),
                  color: itemClicked ? Colors.black12 : widget.backgroundColor,
                  borderRadius: BorderRadius.circular(serviceItemBorderRadius)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10, bottom: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 50,
                      child: widget.icon == null || widget.icon == ""
                          ? 
                          // Icon(
                          //     Icons.album,
                          //     size: 50,
                          //   )
                          nokandaIcon
                          :


                      showCachedImage(widget.icon)
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 3),
                          child: widget.nameMap == null
                              ? Text(
                                  widget.name,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                )
                              : Text(
                                  widget.nameMap[locale] == null ? widget.nameMap["en"] :widget.nameMap[locale],
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                )

                          // ListView(
                          //   shrinkWrap: true,
                          //   scrollDirection: Axis.horizontal,
                          //   children: <Widget>[
                          //     widget.nameMap == null
                          //         ? Text(widget.name)
                          //         : Text(widget.nameMap[locale])

                          //   ],
                          // ),
                          ),
                    ),
                    (widget.hasChildren != null && widget.hasChildren) ||
                            (widget.requiresInput != null &&
                                widget.requiresInput)
                        ? Padding(
                            padding: EdgeInsets.only(left: 3, right: 15),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: accentColor,
                            ),
                          )
                        : Text(""),
                  ],
                ),
              ),
            ),
    );
  }


  bool itemInFav(){
    return _favouritesMap.containsKey(widget.codeToSend);
  }

  showCachedImage(String imageUrl){
    return imageUrl.contains("https://") ? 
                      CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => new Icon(
                                Icons.album,
                                size: 50,
                              ),
                              errorWidget: (context, url, error) => new Icon(
                                Icons.album,
                                size: 50,
                              ),
                            ) 
    :
    
    nokandaIcon;
  }


  populateFavouriteMap() async{
    Map<String, dynamic> favouritesMap = {};


    var id = await getUserID();

    String shortcutUrl = "shortcuts/" + id  + "/shortcuts";
    var userCurrentShortcuts =
    await Firestore.instance.collection(shortcutUrl).getDocuments();

    for (var item in userCurrentShortcuts.documents){
      favouritesMap[item['code']] = true;
    }

    setState(() {
      _favouritesMap = favouritesMap;
    });


  }
}
