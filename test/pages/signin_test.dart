import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kene/auth/signin.dart';


main() {

  // MaterialApp wrapper for widgets to avoid media query errors
  Widget makeTestable(child) => MaterialApp(home: child,);  
  group("all signin widgets are built", (){
      testWidgets("phone number text field widget is built", (WidgetTester tester) async{
        await tester.pumpWidget(makeTestable(Signin()));
      
        expect(find.byKey(Key("phoneNumberTextInput")), findsOneWidget);
      });

      testWidgets("country selector widget is built", (WidgetTester tester) async{
        await tester.pumpWidget(makeTestable(Signin()));
      
        expect(find.byKey(Key("countrySelectorKey")), findsOneWidget);
      });
      

      testWidgets("gender widget is built", (WidgetTester tester) async{
        await tester.pumpWidget(makeTestable(Signin()));
      
        expect(find.byKey(Key("genderWidgetKey")), findsOneWidget);
      });

      testWidgets("login/signhp button is built", (WidgetTester tester) async{
        await tester.pumpWidget(makeTestable(Signin()));
      
        expect(find.byKey(Key("LoginSignupKey")), findsOneWidget);
      });

  });

  // testWidgets("gender widget not shown when on login", (WidgetTester tester) async{
  //     await tester.pumpWidget(makeTestable(Signin()));

  //     // expect(find., matcher)


  // });

  testWidgets("show flushbar when button is clicked and phone number is empty", (WidgetTester tester)async{
   await tester.pumpWidget(makeTestable(Signin()));

    expect(find.byKey(Key("loginButtonClickedLoader")), findsNothing);

    await tester.enterText(find.byKey(Key("phoneNumberTextInput")), "0784650455");
    await tester.tap(find.byKey(Key("LoginSignupKey")));
    await tester.pumpAndSettle(Duration(milliseconds: 10));

    expect(find.byKey(Key("loginButtonClickedLoader")), findsOneWidget); // Check flushar after button is clicked



  }, skip: true);

  // test("test that showFlushbar returns a flushBar widget", () async{

  //   expect(showFlushBar("title", "messge"), Flushbar());
    
  // });
}
 