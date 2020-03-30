import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kene/auth/verify_phone.dart';


main() {

  // MaterialApp wrapper for widgets to avoid media query errors
  Widget makeTestable(child) => MaterialApp(home: child,);  
  group("all verify widgets are built", (){
      // testWidgets("pin text field widget is built", (WidgetTester tester) async{
      //   await tester.pumpWidget(makeTestable(PhoneVerify()));
      
      //   expect(find.byKey(Key("pinTextInput")), findsOneWidget);
      // });

      testWidgets("verify button widget is built", (WidgetTester tester) async{
        await tester.pumpWidget(makeTestable(PhoneVerify()));
      
        expect(find.byKey(Key("verifyPinButton")), findsOneWidget);
      }, skip: true);
      

      // testWidgets("gender widget is built", (WidgetTester tester) async{
      //   await tester.pumpWidget(makeTestable(PhoneVerify()));
      
      //   expect(find.byKey(Key("verifyFlushBar")), findsOneWidget);
      // });

  });
}
