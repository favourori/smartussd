import 'package:flutter/material.dart';

class ReceivePage extends StatelessWidget{

  final qrImage;

  ReceivePage({this.qrImage});
  @override
  build(context){
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Container(

//          width: MediaQuery.of(context).size.width * 0.7,
          margin: EdgeInsets.all(40),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.white
          ),
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Your QR code for receiving MoMo", textAlign: TextAlign.center, style:
              TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
              Container(
                child: qrImage,
              ),
            ],

          ),
        ),
      ),
    );
  }

}