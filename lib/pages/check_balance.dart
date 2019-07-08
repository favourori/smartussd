import 'package:flutter/material.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/utils/stylesguide.dart';

class CheckBalance extends StatelessWidget {

 TextEditingController  _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Check balance"),
      body: Center(
        child: Padding(
          padding:paddingMain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              TextFormField(
                controller: _textController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: EdgeInsets.only(top: 20),
                height: 48,
                child: RaisedButton(
                  onPressed: (){
                    try{
                      launchURL("*182*6*1*${_textController.text}%23");
                    }
                    catch(e){
                      print("could not launch url");
                    }
                  },
                  child: Text("Send"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}