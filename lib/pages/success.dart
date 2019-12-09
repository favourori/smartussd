import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SuccessPage extends StatefulWidget{

  @override
  createState() => _SuccessPageState();
}



class _SuccessPageState extends State<SuccessPage>{

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0);
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
                            CustomPageRoute(navigateTo: Settings()));
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
                            "Thanks for using Nokanda",
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
//            mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 30,),
                            Text("Thanks for using Nokanda, please share with friends and family", textAlign: TextAlign.center, style:
                            TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),

                            SizedBox(height: 30,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RaisedButton(
                                  color: Color(0xff1C1766),
                                  splashColor: Colors.orangeAccent,
                                  padding: EdgeInsets.symmetric(vertical:5, horizontal: MediaQuery.of(context).size.width*0.15),
                                  onPressed: (){},
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.share, color: Colors.white,),
                                    Text("Share", style: TextStyle(
                                      color: Colors.white,
                                    ),)
                                  ],
                                )
                                  ,),

                        SizedBox(
                          width: 15,
                        ),

                        RaisedButton(
                          color: Color(0xff1C1766),
                        splashColor: Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(vertical:5, horizontal: MediaQuery.of(context).size.width*0.15),
                        onPressed: (){},
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.home, color: Colors.white,),
                            Text("Home", style: TextStyle(
                              color: Colors.white,
                            ),)
                          ],
                        )
                        ,)
                              ],
                            ),
//                            SizedBox(height: 30,),
//                            pageButtons("Share", share, Icons.share, context),
//                            SizedBox(height: 70,),
//                            pageButtons("Go back home", (){
//                              Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Carriers()));
//                            }, Icons.home, context),
                            SizedBox(height: 20,),
                            pageButtons("Perform another transaction", (){
                              Navigator.pop(context);
                            }, Icons.loop, context)
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

//      Scaffold(
//      backgroundColor: Colors.orangeAccent,
//      body: Center(
//        child: Container(
//
////          width: MediaQuery.of(context).size.width * 0.7,
//        margin: EdgeInsets.all(40),
//          decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(40),
//            color: Colors.white
//          ),
//          padding: EdgeInsets.all(30),
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              Text("Thanks for using Nokanda, please share with friends and family", textAlign: TextAlign.center, style:
//              TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),),
//              SizedBox(height: 30,),
//              pageButtons("Share", share, Icons.share, context),
//              SizedBox(height: 70,),
//              pageButtons("Go back home", (){
//                Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Carriers()));
//              }, Icons.home, context),
//              SizedBox(height: 20,),
//              pageButtons("Perform another transaction", (){
//                Navigator.pop(context);
//              }, Icons.loop, context)
//            ],
//
//          ),
//        ),
//      ),
//    );
  }






  RaisedButton pageButtons(String label, Function onPressedAction, IconData icon, context){
    return RaisedButton(onPressed: onPressedAction, child:
    Container(
      width: double.infinity,
      height: 55,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Icon(icon, color: Colors.white,),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 8,
              child: Text("$label", style: TextStyle(color: Colors.white),),
            )

          ],
        ),
      ),
    ), color: Color(0xff1C1766), );
  }
}