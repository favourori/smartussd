import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kene/auth/signin.dart';

class Welcome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WelcomState();
  }
}

class _WelcomState extends State<Welcome> {
  PageController _pageController = PageController(initialPage: 0);

  int sizeOfPages = 0;
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  0.1,
                  0.3,
                  0.7,
                  0.95
                ],
                colors: [
                  Color(0xfffb8c00),
                  Color(0xfff57c00),
                  Color(0xffef6c00),
                  Color(0xffe65100),
                ]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                child: Align(
                  alignment: Alignment.topRight,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Signin()));
                    },
                    child: Text(
                      "Skip",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection("settings/welcome/pages").orderBy("order")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                         sizeOfPages = snapshot.data.documents.length; //set size of page to len of document snapshots
                        return PageView(
                          physics: ClampingScrollPhysics(),
                          controller: _pageController,
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          children: populateWelcomePages(snapshot),
                        );
                      }

                      return Container();
                    },
                  ))
            ],
          ),
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Signin()));
        },
        child: _currentPage == sizeOfPages-1
            ? Container(
                height: 70,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "Get started",
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                ),
              )
            : Text(""),
      ),
    );
  }

  Column pageViewItem(BuildContext context, content) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
        ),
        SizedBox(
          height: 150,
          width: 150,
          child:
              // Text("Nokanda", style: TextStyle(fontSize: 30, color: Colors.white),)
              Image.network(
            "${content['image']}",
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Text("${content['title']}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Colors.white)),

        Text("${content['text']}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: displayDots(_currentPage),
        ),
        _currentPage != sizeOfPages-1
            ? Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomRight,
                  child: FlatButton(
                    onPressed: () {
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 450),
                          curve: Curves.easeIn);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          " Next",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  displayDots(activeIndex) {
    List<Widget> tmp = [];

    for (int i = 0; i < sizeOfPages; i++) {
      tmp.add(AnimatedContainer(
        duration: Duration(milliseconds: 400),
        margin: EdgeInsets.only(right: 5),
        height: _currentPage == i ? 10 : 5,
        width: _currentPage == i ? 10 : 5,
        decoration: BoxDecoration(
            color: i == _currentPage ? Colors.white : Colors.grey,
            borderRadius: BorderRadius.circular(
              _currentPage == i ? 5 : 3,
            )),
      ));
    }

    return tmp;
  }

  List<Widget> populateWelcomePages(snapshot) {
    List<Widget> tmp = [];
    for (int i = 0; i < snapshot.data.documents.length; i++) {
      tmp.add(
        pageViewItem(context, snapshot.data.documents[i]),
      );
    }

    return tmp;
  }
}
