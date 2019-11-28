import 'package:flutter/material.dart';

class CollapsibleWidget extends StatefulWidget{
  final question;
  final answer;

  CollapsibleWidget({this.question, this.answer});
  @override
  createState() => _CollapsibleWidget();
}


class _CollapsibleWidget extends State<CollapsibleWidget>{

  bool showAnswer = false;
  @override
  build(context){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              setState(() {
                showAnswer = !showAnswer;
              });
            },
            child: Container(

              child: Row(
                children: <Widget>[
                  Icon(
                      !showAnswer ? Icons.keyboard_arrow_down: Icons.keyboard_arrow_up, size: 20, color:Colors.white),
                  SizedBox(width: 10,),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text("${widget.question}", style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Poppins",
                    ),),
                  )
                ],
              ),
            ),
          ),

          showAnswer ?  Align(
            alignment: Alignment.centerRight,
            child: Opacity(opacity: 0.7,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                margin: EdgeInsets.only(top: 15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
//                  border: Border.all(width: 2,),
                    borderRadius: BorderRadius.only(topLeft:Radius.zero, topRight: Radius.circular(20), bottomLeft: Radius.circular(30), bottomRight: Radius.circular(20) )
                ),
                child: Center(
                  child: Text("${widget.answer}", style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Poppins",
                  ),),
                ),
              ),),
          ): Container()
        ],
      ),
    );
  }
}