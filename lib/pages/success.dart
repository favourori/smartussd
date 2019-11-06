import 'package:flutter/material.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/utils/functions.dart';

class SuccessPage extends StatelessWidget{
  @override
  build(context){
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Thanks for using Nokanda, please share with friends and family", textAlign: TextAlign.center, style:
              TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
              pageButtons("Share", share, Icons.share, context),
              SizedBox(height: 70,),
              pageButtons("Go back home", (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Carriers()));
              }, Icons.home, context),
              SizedBox(height: 20,),
              pageButtons("Perform another transaction", (){
                Navigator.pop(context);
              }, Icons.loop, context)
            ],
            
          ),
        ),
      ),
    );
  }






  RaisedButton pageButtons(String label, Function onPressedAction, IconData icon, context){
    return RaisedButton(onPressed: onPressedAction, child:
    Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 50,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white,),
            SizedBox(
              width: 20,
            ),
            Text("$label", style: TextStyle(color: Colors.white),),

          ],
        ),
      ),
    ), color: Colors.orange, );
  }
}