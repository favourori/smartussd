import 'package:flutter_test/flutter_test.dart';
import 'package:kene/utils/functions.dart' as functions;

void main(){
  test("test for addThousandDelimeter function", (){

    expect(functions.addThousandDelimeter('100'), "100");
    expect(functions.addThousandDelimeter('1000'), "1,000");
    expect(functions.addThousandDelimeter('10000'), "10,000");
    expect(functions.addThousandDelimeter('100000'), "100,000");
    expect(functions.addThousandDelimeter('1000000'), "1,000,000");
  });
}