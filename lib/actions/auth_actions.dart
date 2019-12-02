import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:math';

Future sendAuthSMS(String phone, String code) async{
  print("send auth called =========================>>>>>>>>>>>>>>>>");
    String url = "http://api.pindo.io/v1/sms/";

    String token = "eyJhbGciOiJub25lIn0.eyJpZCI6MjAsInJldm9rZWRfdG9rZW5fY291bnQiOjB9.";
    var headers = {'Authorization': 'Bearer ' + token, "Content-Type": "application/json"};
    var data = jsonEncode({"to" : phone, "text" : "Thank you for using Nokanda, your verification code is $code", "sender" : "Nokanda"});
    var res = await http.post(url, headers: headers, body: data);
    print(data);
    if(res.statusCode == 200){
        return 1;
    }
    else{
      print(res.body);
      return 0;
    }
}

generateVerificationCode(){
  String code ="";

  var random = Random();
  for(int i=0; i <5; i++){
      code += random.nextInt(9).toString();
  }

  return code;
}