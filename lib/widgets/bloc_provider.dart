// Generic Interface for all BLoCs
import 'package:flutter/material.dart';
import 'package:kene/bloc/appBloc.dart';

abstract class BlocBase {
  void dispose();
}

class BlocProvider extends InheritedWidget{
  final AppBloc bloc;

  final Widget child;
  BlocProvider({Key key, @required this.child}): bloc = new AppBloc(), super(key: key, child: child);

  @override
  bool updateShouldNotify(_) => true;

  static AppBloc of(BuildContext context){
    return (context.ancestorWidgetOfExactType(BlocProvider)  as BlocProvider) .bloc;
  }
}

