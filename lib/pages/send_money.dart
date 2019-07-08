import 'package:flutter/material.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:native_contact_picker/native_contact_picker.dart';

class SendMoney extends StatelessWidget {

  // ContactPicker contactPicker = new ContactPicker();

  getContact() async{
  final NativeContactPicker _contactPicker = new NativeContactPicker();
  Contact contact = await _contactPicker.selectContact();
  print(contact.phoneNumber);
  }

 TextEditingController  _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Send money"),
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
                      getContact();
                    }
                    catch(e){
                      print("could not select contact");
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