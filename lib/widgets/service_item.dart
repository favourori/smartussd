import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class ServiceItem extends StatefulWidget{
  final backgroundColor;
  final icon;
  final name;
  final serviceLabel;
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


  ///
  ///operations done and sent to parent
  ///

  final serviceActions;


  ServiceItem({this.backgroundColor, this.serviceLabel, this.needsContact, this.requiresInput,
    this.needsRecipient, this.codeToSend, this.recipientLabel, this.canSaveLabels, this.needsAmount,
    this.requiresCamera, this.hasChildren, this.serviceDescription, this.parentID, this.icon, this.name,
    this.serviceActions});

  @override
  createState() => _ServiceItemState();
}


class _ServiceItemState extends State<ServiceItem>{

 bool itemClicked = false;
  @override
  build(context){
    return
      GestureDetector(
        onTap: () {
          setState(() {
            itemClicked = true;
          });

          Future.delayed(Duration(milliseconds: 300)).then((f){ // delay for 300 milli secs before Navigating

            //          var hT = headTitleStack;
//          if (list['requiresInput'] != null && list['requiresInput']) {
//            hT.add(list['name']);
//          }

//          setState(() {
//            headTitleStack = hT;
//            serviceLable = list['label'];
//            needsContact = list['needsContact'];
//            needsRecipient = list['needsRecipient'];
//            codeToSend = list['code'];
//            recipientLabel = list['recipientLabel'];
//            canSaveLabels = list['canSaveLabels'];
//            needsAmount = list['needsAmount'];
//            requiresCamera = list["requiresCamera"];
//            serviceDescription = list["serviceDescription"];
//            hasChildren =
//            list['hasChildren'] != null ? list['hasChildren'] : false;
//            parentID = list.documentID;
//          });

            // sending name for parent to update to update header title
            String name = widget.requiresInput != null && widget.requiresInput ? widget.name : null;

            if (widget.hasChildren != null && widget.hasChildren) {

              /// UPDATE THE COLLECTION URL IF THERE'S CHILDREN FOR THE TREE TO REBUILD
              String newURL = "/" + widget.parentID + "/children";
              widget.serviceActions(newURL, 0, {"label":widget.serviceLabel, "name":name});  //motive of 0, when it has children, and empty data
            }
            /// if requires input, send code to parent to make the call
          else if (!widget.requiresInput) {
            widget.serviceActions(null, 1, {"code": widget.codeToSend, "label":widget.serviceLabel, "name":name});
          } else {

            /// call parent to open up action center
              widget.serviceActions(null, 2, {"label":widget.serviceLabel, "name":name});

          }
          });

        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          height: 70,
          decoration: BoxDecoration(
            // border: Border.all(color: widget.primaryColor),
              color: itemClicked ? Color(0xffB9BBBD) : widget.backgroundColor,
              borderRadius: BorderRadius.circular(40)),
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
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[Text(widget.name)],
                    ),
                  ),
                ),
                (widget.hasChildren != null && widget.hasChildren) || (widget.requiresInput != null && widget.requiresInput)
                    ? Padding(
                  padding: EdgeInsets.only(left: 3, right: 15),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 25,
                    color: Colors.grey,
                  ),
                )
                    : Text(""),
              ],
            ),
          ),
        ),
    );
  }
}