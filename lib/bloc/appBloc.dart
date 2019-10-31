import 'dart:async';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';


class AppBloc implements BlocBase {

  /////////// ============= actions ================== \\\\\\\\\\\\\\\


  /////////// ============= streams ================== \\\\\\\\\\\\\\\

  final StreamController<String> _amountStreamController = BehaviorSubject();
  final StreamController<String> _recipientStreamController = BehaviorSubject();
  final StreamController<String> _headerTitleStreamController = BehaviorSubject();
  final StreamController<Map<String, dynamic>> _serviceDataController = BehaviorSubject();

  /////////// ============= get methods ================== \\\\\\\\\\\\\\\

  get amountIn => _amountStreamController.stream;
  get amountOut => _amountStreamController.sink.add;

  get recipientIn => _recipientStreamController.stream;
  get recipientOut => _recipientStreamController.sink.add;

  get headerTitleIn => _headerTitleStreamController.stream;
  get headerTitleOut => _headerTitleStreamController.sink.add;

  get serviceDataIn => _serviceDataController.stream;
  get serviceDataOut => _serviceDataController.sink.add;

  @override
  void dispose() {
    _amountStreamController.close();
    _recipientStreamController.close();
    _headerTitleStreamController.close();
    _serviceDataController.close();

  }
}
