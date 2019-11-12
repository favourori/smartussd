import 'package:flutter/material.dart';
import 'package:kene/bloc/appBloc.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/bloc_provider.dart';

class ChooseLanguage extends StatefulWidget {
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
      height: 100,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          DropdownButton(
            icon: Icon(Icons.arrow_drop_down, color: Colors.orange,),
            value: languageValue,
            onChanged: (v){

              setState(() {
                languageValue = v;
                appBloc.localeIn(v);
                setLocale(v);
              });
            },
            items: <DropdownMenuItem>[
              DropdownMenuItem(value: "select",
              child: Text("Select"),),
              DropdownMenuItem(value: "en",
                child: Text("English"),),
              DropdownMenuItem(value: "kw",
                child: Text("KinyaRwanda"),),
              DropdownMenuItem(value: "fr",
                child: Text("French"),),
            ],
          ),

          RaisedButton(child: Text("Close"),onPressed: (){
            Navigator.pop(context);
          },)
        ],
      ),
    );
  }
}
