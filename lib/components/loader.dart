import 'package:flutter/material.dart';
import 'package:kene/utils/stylesguide.dart';


class NLoader extends StatefulWidget {
  @override
  _NLoaderState createState() => _NLoaderState();
}

class _NLoaderState extends State<NLoader>  with SingleTickerProviderStateMixin {

  AnimationController _fadeTransition;
  Animation opacityAnimation;

  listener(){
    if(_fadeTransition.isCompleted){
      _fadeTransition.reverse();

    }

    else if(_fadeTransition.isDismissed){
      _fadeTransition.forward();
    }

  }

  @override
  void dispose() {

    _fadeTransition.dispose();
    super.dispose();


  }


  @override
  void initState() {
    super.initState();

    _fadeTransition = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    opacityAnimation = Tween<double>(begin: 0.2, end: 1).animate(CurvedAnimation(parent: _fadeTransition, curve: Curves.bounceIn));
    _fadeTransition.forward();
    _fadeTransition.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacityAnimation,
      child: Container(
//        height: 300,
        decoration: BoxDecoration(
//          color: Colors.grey,
        ),
        width: double.infinity,
        child: Column(
          children: makePlaceHolderServices(),
        ),
      ),
    );
  }


  List<Widget> makePlaceHolderServices(){
    List<Widget> tmp  = [];

    Container  placeholderService = Container(
      height: 70,
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(serviceItemBorderRadius),
//        border: Border.all(color: Colors.grey)

      ),
    );

    for(int x = 0; x < 4; x++){
      tmp.add(placeholderService);

    }
    return tmp;
  }


}
