import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/custom_nav.dart';

class ReceivePage extends StatefulWidget{

  final qrImage;
  final analytics;

  ReceivePage({this.qrImage, this.analytics});


  @override
  createState() => _ReceivePageState();
}



class _ReceivePageState extends State<ReceivePage>{
  ScrollController _scrollController;
  String phone = "";

  @override
  void initState() {
    super.initState();

    // Send analytics on page load/initialize
    sendAnalytics(widget.analytics, "BarCodePage_Open", null);

    _scrollController = ScrollController(initialScrollOffset: 0);

    FirebaseAuth.instance.currentUser().then((data){
      if(data != null){
        setState(() {
          phone = " on " + data.phoneNumber;
        });
      }
    });
  }

  @override
  build(context){
    return

      Scaffold(
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
                  leading: IconButton(icon: Icon(Icons.arrow_back), onPressed:()=> Navigator.pop(context)),
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
                            "Receive MoMo",
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
                        child:
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Your QR code for receiving MoMo $phone", textAlign: TextAlign.center, style:
                              TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),),
                              SizedBox(height: 30,),
                              Container(
                                child: widget.qrImage,
                              ),
                            ],

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

}