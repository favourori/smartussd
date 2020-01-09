import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:kene/utils/functions.dart';

class ShortcutItem extends StatefulWidget{
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

  //
  // Operations done and sent to parent
  //

  final serviceActions;


  ShortcutItem({this.backgroundColor, this.carrierID, this.needsScan, this.primaryColor, this.label, this.nameMap, this.needsContact, this.requiresInput,
    this.needsRecipient, this.codeToSend, this.recipientLabel, this.canSaveLabels, this.needsAmount,
    this.requiresCamera, this.hasChildren, this.serviceDescription, this.parentID, this.icon, this.name,
    this.serviceActions});

  @override
  createState() => _ShortcutItemState();
}


class _ShortcutItemState extends State<ShortcutItem>{

  bool itemClicked = false;
  String locale = "en";
  var appBloc;


  Map<String, dynamic> data;

  @override
  void initState() {

    data = {
      "backgroundColor": widget.backgroundColor,
      "icon": widget.icon,
      "name":widget.name,
      "label":widget.label,
      "needsContact":widget.needsContact,
      "needsRecipient":widget.needsRecipient,
      "requiresInput":widget.requiresInput,
      "code":widget.codeToSend,
      "recipientLabel":widget.recipientLabel,
      "canSaveLabels":widget.canSaveLabels,
      "needsAmount":widget.needsAmount,
      "requiresCamera":widget.requiresCamera,
      "serviceDescription":widget.serviceDescription,
      "hasChildren":widget.hasChildren,
      "parentID":widget.parentID,
      "needsScan": widget.needsScan,
    };

    super.initState();


    // Get locale from stream
    appBloc = BlocProvider.of(context);

    appBloc.localeOut.listen((data){
      setState(() {
        locale = data != null ? data : locale;
      });
    });
  }

  @override
  build(context){
    return
      GestureDetector(
        onTap: () {


          Future.delayed(Duration(milliseconds: 50)).then((f){ // delay for 300 milli secs before Navigating
            // Restore the boolean to revert the background color
            setState(() {
              itemClicked = false;
            });

            // sending name for parent to update to update header title
            String name = widget.requiresInput != null && widget.requiresInput ? widget.name : null;

            if (widget.hasChildren != null && widget.hasChildren) {

              /// UPDATE THE COLLECTION URL IF THERE'S CHILDREN FOR THE TREE TO REBUILD
              String newURL = "/" + widget.parentID + "/children";
              widget.serviceActions(newURL, 0, {"label":widget.label, "name":name});  //motive of 0, when it has children, and empty data
            }
            /// if does not require input, send code to parent to make the call
            else if (!widget.requiresInput) {
              widget.serviceActions(null, 1, {"code": widget.codeToSend, "label":widget.label, "name":name});
            } else {



              appBloc.serviceDataIn(data);


              /// call parent to open up action center
              widget.serviceActions(null, 2, {"label":widget.label, "name":name});

            }
          });

          setState(() {
            itemClicked = true;
          });

        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          height: 80,
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
                  child: widget.icon == null || widget.icon == "" ? Icon(
                    Icons.album,
                    size: 50,
                  ):
                  CachedNetworkImage(
                    imageUrl: widget.icon,
                    placeholder: (context, url) => new Icon(
                      Icons.album,
                      size: 50,
                    ),
                    errorWidget: (context, url, error) => new Icon(
                      Icons.album,
                      size: 50,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 3),
                      child: widget.nameMap == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.name, style: TextStyle(
                              fontWeight: FontWeight.w600
                          ),)
                          ,

                          Text(widget.carrierID.toString().toUpperCase(), style: TextStyle(
                              fontSize: 12
                          ),)

                        ],
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.nameMap[locale], style: TextStyle(
                              fontWeight: FontWeight.w600
                          ),),
                          Text(widget.carrierID.toString().toUpperCase(), style: TextStyle(
                            fontSize: 12
                          ),)
                        ],
                      )
                  ),
                ),

                IconButton(icon: Icon(Icons.delete, color: Colors.redAccent, size: 25,), onPressed: (){
                  deleteShortcut(widget.parentID);

                }),
//                (widget.hasChildren != null && widget.hasChildren) || (widget.requiresInput != null && widget.requiresInput)
//                    ? Padding(
//                  padding: EdgeInsets.only(left: 3, right: 15),
//                  child: Icon(
//                    Icons.arrow_forward_ios,
//                    size: 25,
//                    color: widget.primaryColor,
//                  ),
//                )
//                    : Text(""),
              ],
            ),
          ),
        ),
      );
  }

}