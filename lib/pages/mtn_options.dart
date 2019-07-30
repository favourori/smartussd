import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kene/database/db.dart';

import 'package:kene/utils/functions.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:native_contact_picker/native_contact_picker.dart';

class MtnOptions extends StatefulWidget {
  final observer;
  final analytics;

  MtnOptions({this.analytics, this.observer});
  @override
  State<StatefulWidget> createState() {
    return _MtnOptionsState();
  }
}

class _MtnOptionsState extends State<MtnOptions> with TickerProviderStateMixin {
  static const platform = const MethodChannel('com.kene.momouusd');


  String buttonClicked = "";
  KDB db = KDB();

  List meterList = [];
  Animation<double> positionAnimation;
  Animation slideAnimationOut;
  Animation slideAnimationOut2;
  Animation slideAnimationIn;
  Animation slideAnimationIn2;

  AnimationController _positionAnimationController;
  AnimationController _animationController;
  AnimationController _animationController3;
  AnimationController _animationController2;
  TextEditingController _inputController = TextEditingController();
  ScrollController _listController = ScrollController();

  int showId = 0;
  bool inputNotEmpty = false;
  bool isBtnClicked = false;
  String number = "";
  String amountToSend = "";
  String BASEURL = "*182*";
  bool isAmountStage = false;
  Color floatingColor = Colors.red[700];
  final double paddingValue = 0;
  List<Color> colorsList = [Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white, Colors.white];

  _sendCode(code) async{
    try{
      print(code);
      await platform.invokeMethod("moMoDialNumber", {"code": code});
    }on PlatformException catch(e){
      print("error check balance is $e");
    }
  }

  @override
  void initState() {
    _inputController.addListener(inputControllerListener);

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    _animationController2 = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    _animationController3 = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    slideAnimationOut = Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0))
        .animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.2, 0.5, curve: Curves.easeInOut)));

    slideAnimationOut2 = Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0))
        .animate(CurvedAnimation(
        parent: _animationController2,
        curve: Interval(0.2, 0.5, curve: Curves.easeInOut)));


    slideAnimationIn = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.2, 0.6, curve: Curves.easeInOut)));

    slideAnimationIn2 = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
        parent: _animationController3,
        curve: Interval(0.2, 0.6, curve: Curves.easeInOut)));

    _positionAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    positionAnimation =
        Tween<double>(begin: 1, end: 7).animate(_positionAnimationController);

    _listController.addListener(listener);

    getSavedMeters();
    super.initState(); 
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    _animationController3.dispose();
    _positionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showId == 0
          ? appBar("Choose Options")
          : showId == 1 ? appBar("Check balance") : appBar("Choose Options"),
      floatingActionButton: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Colors.red[700], borderRadius: BorderRadius.circular(25)),
        child: Material(
            color: floatingColor,
            borderRadius: BorderRadius.circular(25),
            elevation: 10,
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: positionAnimation.value,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        floatingColor = Colors.red[200];
                      });

                      Timer(Duration(milliseconds: 300), (){
                        setState(() {
                        floatingColor = Colors.red[700];
                        isAmountStage = false;
                        _inputController.text = "";
                      });
                      });
                      _positionAnimationController.reset();
                      _positionAnimationController.forward().then((_)=>
                        _positionAnimationController.reverse()
                      );

                      resetAll();
                      scrollListView(0, 0);
                    },
                    icon: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )),
      ),
      backgroundColor: pageBackground,
      body: Padding(
        padding: paddingMain,
        child: ListView(
          // reverse: true,
          controller: _listController,
          children: <Widget>[
            optionsCard("Check balance", "balance.png", 1),
            optionsCard("Send money", "send_money.png", 2),
            optionsCard("Buy/Send Airtime", "buy.png", 3),
//            optionsCard("Buy Internet Bundle", "internet.png", 4),
            optionsCard("Buy Electricity (CashPower Pivot)", "electricity.png", 6),
            optionsCard("Buy Bus Tap & Go", "bus.png", 5),
            optionsCard("Get money from bank", "bank.ico", 7),

            showId == 1
                ? checkBalancePage()
                : showId == 2 ? sendMoney() : showId == 3 ? buyAirtime() : showId == 6 ? buyElectricity(): Container(),
          ],
        ),
      ),
    );
  }

  Widget optionsCard(title, image, id) {
    return GestureDetector(
      onTap: () {
        switch(id){
          case 1:
            {
              setState(() {
                buttonClicked = "check_balance_btn";
              });
            }
            break;

          case 2:
            {
              setState(() {
                buttonClicked = "send_money_btn";
              });
            }
            break;

          case 3:
            {
              setState(() {
                buttonClicked = "buy/send_airtime_btn";
              });
            }
            break;

          case 6:
            {
              setState(() {
                buttonClicked = "buy_electricity_btn";
              }); 
            }
            break;

          default:
            {
              setState(() {
                buttonClicked = "unregistered_btn";
              });
            }
            break;


        }

        sendAnalytics(widget.analytics, buttonClicked, null);

        if(id == 5 || id == 7){
          comingSoon();

        }else{

          setState(() {
            colorsList[id] = Colors.grey[400];
            showId = id;
            isBtnClicked = true;
          });
          Timer(Duration(
            milliseconds: 300,
          ),

                  (){
                scrollListView(560.8, id);
              });

        }


      },
      child: Container(
       
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
               color: colorsList[id]),
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/$image"))),
                ),
                Flexible(
                  child:Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(

                    "$title",
                    style: subHeading,
                  ),
                ))
              ],
            ),
          )),
    );
  }

  Widget checkBalancePage() {
    return getPin(1);
  }

  Container getPin(id) {
    return Container(
    margin: EdgeInsets.only(top: 20),
    height: MediaQuery.of(context).size.height,
    child: Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical:20.0),
              child: Text(
                "Enter mobile money pin",
                style: headingBold,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15)),
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                    children: [
                      TextFormField(
                        controller: _inputController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Enter mobile money pin",
                            labelStyle: normalText),
                      ),
                      Text(
                        "Assurance: Your pin is not stored and is secured",
                        style: label,
                      ),
                      SizedBox(
                        height: 45,
                      ),
                      Container(
                        width: double.infinity,
                        height: 48,
                        child: RaisedButton(
                          onPressed: !inputNotEmpty
                              ? null
                              : (){

                            //send analytics of button

                            sendAnalytics(widget.analytics, buttonClicked+"_sent", null);
                            String code = BASEURL;

                            if(id == 1){
                              code += "6*1*" + _inputController.text;
                            }
                            else if(id == 2){
                              code += "1*1*" + number +"*"+ amountToSend + "*"+ _inputController.text;
                            }

                            else if(id == 3){
                              code += "2*1*1*" + amountToSend +"*"+ number + "*"+ _inputController.text;
                            }
                            else if(id == 5){
                              code += "2*5*1*" + amountToSend +"*"+ number + "*"+ _inputController.text;
                            }

                            // electricity
                            else if(id == 6){
                              code += "2*2*2*1*" + amountToSend +"*1*"+ number + "*"+ _inputController.text;
                            }

                            _sendCode(code);
                            setState(() {
                              _inputController.text = "";
                              isAmountStage = false;
                            });

                              resetAll();
                          },
                          color: Colors.orange,
                          child: Text(
                            "Send",
                            style: btnTextNormalWhite,
                          ),
                        ),
                      )
                    ]),
              ),
            )
          ],
        ),
      ],
    ),
  );
  }

  Widget sendMoney() {
    return Stack(
      children: <Widget>[

        //enter contact
        SlideTransition(
          position: slideAnimationOut,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Send money",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter number",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter number to send to",
                              style: label,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: Text(
                              "OR",
                              style: heading,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 25),
                            width: double.infinity,
                            height: 48,
                            child: RaisedButton(
                              onPressed: () {
                                getContact();
                              },
                              color: Colors.grey[500],
                              child: Text(
                                "Choose Contact",
                                style: btnTextNormalWhite,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {
                                        setState(() {
                                          number = _inputController.text;
                                          _inputController.text = "";

                                        });



                                        animateSlide();

                                        Timer(Duration(milliseconds: 1500), (){
                                          setState(() {
                                            isAmountStage = true;
                                          });
                                        });
                                      },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter amount
        SlideTransition(
          position: !isAmountStage ? slideAnimationIn : slideAnimationOut2,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Amount",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter amount",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter amount to send",
                              style: label,
                            ),
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {

                                        setState(() {
                                            amountToSend = _inputController.text;
                                          _inputController.text = "";

                                        });

                                        _animationController2.reset();
                                        _animationController2.forward();
                                        _animationController3.reset();
                                        _animationController3.forward();


                                      },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isAmountStage = false;
                                  });
                                  reverseSlide();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.orange,
                                ),
                              ))
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter pin
        SlideTransition(
          position: slideAnimationIn2,
          child: getPin(2),
        )
      ],
    );
  }

  Widget buyAirtime() {
    return Stack(
      children: <Widget>[

        //enter contact
        SlideTransition(
          position: slideAnimationOut,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Buy Airtime",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter number",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter number to send to",
                              style: label,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: Text(
                              "OR",
                              style: heading,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 25),
                            width: double.infinity,
                            height: 48,
                            child: RaisedButton(
                              onPressed: () {
                                getContact();
                              },
                              color: Colors.grey[500],
                              child: Text(
                                "Choose Contact",
                                style: btnTextNormalWhite,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {
                                  setState(() {
                                    number = _inputController.text;
                                    _inputController.text = "";

                                  });



                                  animateSlide();

                                  Timer(Duration(milliseconds: 1500), (){
                                    setState(() {
                                      isAmountStage = true;
                                    });
                                  });
                                },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter amount
        SlideTransition(
          position: !isAmountStage ? slideAnimationIn : slideAnimationOut2,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Amount",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter amount",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter amount to send",
                              style: label,
                            ),
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {

                                  setState(() {
                                    amountToSend = _inputController.text;
                                    _inputController.text = "";

                                  });

                                  _animationController2.reset();
                                  _animationController2.forward();
                                  _animationController3.reset();
                                  _animationController3.forward();


                                },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isAmountStage = false;
                                  });
                                  reverseSlide();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.orange,
                                ),
                              ))
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter pin
        SlideTransition(
          position: slideAnimationIn2,
          child: getPin(3),
        )
      ],
    );
  }

  Widget buyBusTapNGo() {
    return Stack(
      children: <Widget>[

        //enter contact
        SlideTransition(
          position: slideAnimationOut,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Buy Bus Tap & Go",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.text,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter card number",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter card number to top up",
                              style: label,
                            ),
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {
                                  setState(() {
                                    number = _inputController.text;
                                    _inputController.text = "";

                                  });



                                  animateSlide();

                                  Timer(Duration(milliseconds: 1500), (){
                                    setState(() {
                                      isAmountStage = true;
                                    });
                                  });
                                },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter amount
        SlideTransition(
          position: !isAmountStage ? slideAnimationIn : slideAnimationOut2,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Amount",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter amount",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter amount to top up",
                              style: label,
                            ),
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {

                                  setState(() {
                                    amountToSend = _inputController.text;
                                    _inputController.text = "";

                                  });

                                  _animationController2.reset();
                                  _animationController2.forward();
                                  _animationController3.reset();
                                  _animationController3.forward();


                                },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isAmountStage = false;
                                  });
                                  reverseSlide();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.orange,
                                ),
                              ))
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter pin
        SlideTransition(
          position: slideAnimationIn2,
          child: getPin(5),
        )
      ],
    );
  }

  Widget buyElectricity() {
    return Stack(
      children: <Widget>[

        //enter contact
        SlideTransition(
          position: slideAnimationOut,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Buy Electricity",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter meter number",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter meter number to top up",
                              style: label,
                            ),
                          ),

                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "OR",
                                  style: label,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Choose from saved",
                                  style: label,
                                ),
                              ),
                              
                              Container(
                                margin: EdgeInsets.only(top: 15),
                                height: 40,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: displaySavedMeterNumbers()
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {
                                  setState(() {
                                    number = _inputController.text;
                                    _inputController.text = "";

                                  });



                                  animateSlide();

                                  Timer(Duration(milliseconds: 1500), (){
                                    setState(() {
                                      isAmountStage = true;
                                    });
                                  });
                                },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter amount
        SlideTransition(
          position: !isAmountStage ? slideAnimationIn : slideAnimationOut2,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Amount",
                        style: headingBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(children: [
                          TextFormField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            // obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter amount",
                                labelStyle: normalText),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Enter amount to top up",
                              style: label,
                            ),
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 150,
                              height: 48,
                              child: RaisedButton(
                                onPressed: !inputNotEmpty
                                    ? null
                                    : () {

                                  setState(() {
                                    amountToSend = _inputController.text;
                                    _inputController.text = "";

                                  });

                                  _animationController2.reset();
                                  _animationController2.forward();
                                  _animationController3.reset();
                                  _animationController3.forward();


                                },
                                color: Colors.orange,
                                child: Text(
                                  "Next",
                                  style: btnTextNormalWhite,
                                ),
                              ),
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isAmountStage = false;
                                  });
                                  reverseSlide();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.orange,
                                ),
                              ))
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //enter pin
        SlideTransition(
          position: slideAnimationIn2,
          child: getPin(6),
        )
      ],
    );
  }

  comingSoon(){
     showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: Text("Coming soon"),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.pop(context);
                
              },
              child: Text("okay"),
            )
          ],
        );
      }
   
    );
  }

  void resetAll(){
    _animationController3.reset();
    _animationController2.reset();
    _animationController.reset();
  }
  void animateSlide() {
    _animationController.reset();
    _animationController.forward().then((_) => resetButtonClicked());
  }

  void reverseSlide() {
    _animationController.reverse().then((_) => resetButtonClicked());
  }

  void scrollListView(double to, id) {
    setState(() {
      colorsList[id] = Colors.white;
    });
    _listController
        .animateTo(to,
            duration: Duration(milliseconds: 500), curve: Curves.easeInOut)
        .then((_) => resetButtonClicked());
  }

  listener() {
    // setState(() {
    //   _inputController.text = null;
    // });

    if (_listController.offset < 183 && !isBtnClicked) {
      setState(() {
        showId = 0;
      });
    }
  }

  void resetButtonClicked() {
    setState(() {
      isBtnClicked = false;
    });
  }

  getContact() async {
    final NativeContactPicker _contactPicker = new NativeContactPicker();
    Contact contact = await _contactPicker.selectContact();
    if (contact != null) {
      String number = "";
      for (int x = 0; x < contact.phoneNumber.length; x++) {
        if (contact.phoneNumber[x] != " ") {
          number += contact.phoneNumber[x];
        }
      }

      String numberToStore = number.contains("+250") ? number.substring(3) : number;
      setState(() {
        _inputController.text = numberToStore;
      });
    }
    // print(contact.phoneNumber);
  }

  inputControllerListener() {
    // print(_inputController.text);
    if (_inputController.text != null && _inputController.text.length > 0) {
      setState(() {
        inputNotEmpty = true;
      });
    } else {
      setState(() {
        inputNotEmpty = false;
      });
    }
  }

  getSavedMeters() async{
    await db.intiDB();
    var res = await db.retrieve("meter");
    setState(() {
      meterList = res;
    });
  }

  List<Widget> displaySavedMeterNumbers() {

      List<Widget> temp = [];


      for(Map x in meterList){
        temp.add(
           Container(
             margin: EdgeInsets.only(right: 5),
             child:  RaisedButton(
               color:Colors.orange,
               onPressed: (){
                 setState(() {
                   _inputController.text = x['number'];
                 });
               },
               child: Text("${x['label']}", style: normalTextWhite,),
             ),
           )

        );
      }

      return temp;

  }
}
