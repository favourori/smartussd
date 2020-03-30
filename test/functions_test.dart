import 'package:flutter_test/flutter_test.dart';
import 'package:kene/utils/functions.dart' as functions;

void main(){
  test("test for addThousandDelimeter function", (){

    expect(functions.addThousandDelimeter(''), "");
    expect(functions.addThousandDelimeter('100'), "100");
    expect(functions.addThousandDelimeter('1000'), "1,000");
    expect(functions.addThousandDelimeter('10000'), "10,000");
    expect(functions.addThousandDelimeter('100000'), "100,000");
    expect(functions.addThousandDelimeter('1000000'), "1,000,000");
  });


  test("test for getTextFromPageData function", () async{

    var data1 = {
      "signin":{
        "en":"Login",
        "fr":"Lögin",
      }
    };

    // No string key present in test data
    expect(functions.getTextFromPageData(data1, "logout", "en"), "");

    // No locale present in data 
    expect(functions.getTextFromPageData(data1, "signin", "ki"), "Login");

    // Key and locale present in data
    expect(functions.getTextFromPageData(data1, "signin", "fr"), "Lögin");
    

  
  });


   test("test for isNumeric function", () async{

    expect(functions.isNumeric("345"), true);
    expect(functions.isNumeric("abc"), false);
    expect(functions.isNumeric("12345"), true);
    expect(functions.isNumeric("-123"), true);

  
  }, skip: false);


   test("test for computeCodeToSend function", () async{

    expect(functions.computeCodeToSend("*182*N*A", "4000","0784650455"), "*182*0784650455*4000");
    expect(functions.computeCodeToSend("*182*2*A", "4000","0784650455"), "*182*2*4000");
    expect(functions.computeCodeToSend("*182*1*3*A*N","2500","0784650455",), "*182*1*3*2500*0784650455");
    

  
  }, skip: false);

}