import 'dart:async';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';


class AppBloc implements BlocBase {

  /////////// ============= actions ================== \\\\\\\\\\\\\\\


  /////////// ============= streams ================== \\\\\\\\\\\\\\\

  final StreamController<String> _amountStreamController = BehaviorSubject();
  final StreamController<String> _recipientStreamController = BehaviorSubject();
  final StreamController<String> _headerTitleStreamController = BehaviorSubject();
//  final StreamController<int> _primaryColorStreamController = BehaviorSubject();
  final StreamController<Map<String, dynamic>> _serviceDataController = BehaviorSubject();

  /////////// ============= get methods ================== \\\\\\\\\\\\\\\

  get amountOut => _amountStreamController.stream;
  get amountIn => _amountStreamController.sink.add;


//  get primaryColorOut => _primaryColorStreamController.stream;
//  get primaryColorIn => _primaryColorStreamController.sink.add;

  get recipientOut => _recipientStreamController.stream;
  get recipientIn => _recipientStreamController.sink.add;

  get headerTitleOut => _headerTitleStreamController.stream;
  get headerTitleIn => _headerTitleStreamController.sink.add;

  get serviceDataOut => _serviceDataController.stream;
  get serviceDataIn => _serviceDataController.sink.add;

  @override
  void dispose() {
    _amountStreamController.close();
    _recipientStreamController.close();
    _headerTitleStreamController.close();
    _serviceDataController.close();
//    _primaryColorStreamController.close();

  }
}
