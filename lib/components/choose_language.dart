import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kene/bloc/appBloc.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/bloc_provider.dart';

class ChooseLanguage extends StatefulWidget {
  final languageList;

  ChooseLanguage({this.languageList});
  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {

String languageValue = "select";

AppBloc appBloc;

  @override
  void initState() {
    super.initState();




    appBloc = BlocProvider.of(context);

    appBloc.localeOut.listen((data){
      setState(() {
          languageValue = data;
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: Platform.isIOS  ? 300: 100,
      color: Platform.isIOS ? null : Colors.white,
      child:
      Platform.isIOS ?
      CupertinoPicker(itemExtent: 40, onSelectedItemChanged: (v){
        // TODO: handle Cupertino language picker onSelect
        languageAction(widget.languageList[v-1]['locale']);
      }, children: displayIOSPickerChildren())
          :

      Column(
        children: <Widget>[
          DropdownButton(
            icon: Icon(Icons.arrow_drop_down, color: Colors.orange,),
            value: languageValue,
            onChanged: (v){

              setState(() {
                languageValue = v;
                languageAction(v);

              });
            },
            items: displayAndroidDropDownChildren()
          ),

          RaisedButton(child: Text("Close"),onPressed: (){
            Navigator.pop(context);
          },)
        ],
      ),
    );
  }

  TextStyle pickerTextStyle = TextStyle(fontSize: 18);


List<Widget> displayIOSPickerChildren(){
  List<Widget> tmp = [Text("Select", style: pickerTextStyle,)];
  for(int i =0; i < widget.languageList.length; i++){
    tmp.add(Text("${widget.languageList[i]['label']}", style: pickerTextStyle,));

  }

  return tmp;
}



List<DropdownMenuItem> displayAndroidDropDownChildren(){

  // Initialize android dropdown with the default select value
  List<DropdownMenuItem> tmp = [

    DropdownMenuItem(value: "select",
    child: Text("Select"),),

  ];
  for(int i =0; i < widget.languageList.length; i++){
    tmp.add(
      DropdownMenuItem(value: "${widget.languageList[i]['locale']}",
        child: Text("${widget.languageList[i]['label']}"),),
    );

  }

  return tmp;
}

languageAction(v){
  appBloc.localeIn(v);
  setLocale(v);
}


}
