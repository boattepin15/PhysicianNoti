import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/menu/Addprofile.dart';
import 'package:flutter_application_1/menu/Report.dart';
import 'package:flutter_application_1/menu/Report2.dart';
import 'package:flutter_application_1/ui/Home.dart';

class menulist extends StatefulWidget {
  const menulist({super.key});

  @override
  State<menulist> createState() => _menulistState();
}

class _menulistState extends State<menulist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f9),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 40,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          "คุณต้องการเพิ่มอะไร?",
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontFamily: 'SukhumvitSet-Bold',
          ),
        ),
        actions: const [],
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        margin: EdgeInsets.only(top: 30.0),
        child: ListView(children: [
          InkWell(
            onTap: () {
              _pushPageAddProfile(context, false);
            },
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/images/profile.png'),
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 5,
                    child: Text("ข้อมูลโปรไฟล์ผู้ใช้งาน",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25.0,
                            fontFamily: 'SukhumvitSet-Bold'),
                        textAlign: TextAlign.start),
                  ),
                ],
              ),
            ),
          ),

          InkWell(
            onTap: () {
              _pushPageReport(context, false);
            },
            child: Container(
              padding: const EdgeInsets.only(left: 25, right: 20, top: 30),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/images/report_medicine.png'),
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 5,
                    child: Text("ประวัติการทานยา",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25.0,
                            fontFamily: 'SukhumvitSet-Bold'),
                        textAlign: TextAlign.start),
                  ),
                ],
              ),
            ),
          ),

          ////////////////////////ข้อมูลยา/////////////////////////////////
          // InkWell(
          //     onTap: (){
          //       _pushPageListMedicine(context,false);
          //     },
          //     child:  Container(
          //           padding: const EdgeInsets.only(left: 20,right: 20,top:10),
          //           child:  const Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: <Widget>[
          //               Image(
          //                 image: AssetImage('assets/images/info_medicine.png'),
          //                 height: 80,
          //                 width: 80,
          //               ),
          //               SizedBox(width: 10,),
          //               Expanded(
          //                 flex: 5,
          //                 child:  Text(
          //                     "ข้อมูลยา",
          //                     style: TextStyle(
          //                         color: Colors.black,
          //                         fontSize: 25.0,
          //                         fontFamily: 'SukhumvitSet-Bold'),
          //                     textAlign: TextAlign.start
          //                 ),
          //               ),

          //             ],
          //           ),
          //         ),
          // )
        ]),
      ),
    );
  }

  void _pushPageAddProfile(BuildContext context, bool isHorizontalNavigation) {
    Navigator.of(context, rootNavigator: !isHorizontalNavigation)
        .push(
      _buildAdaptivePageRoute(
        builder: (context) => const Addprofile(),
        fullscreenDialog: !isHorizontalNavigation,
      ),
    )
        .then((value) {
      const Duration(seconds: 2);
      // ReloadData();
    });
  }

  void _pushPageReport(BuildContext context, bool isHorizontalNavigation) {
    Navigator.of(context, rootNavigator: !isHorizontalNavigation)
        .push(
      _buildAdaptivePageRoute(
        builder: (context) => const Report2(),
        fullscreenDialog: !isHorizontalNavigation,
      ),
    )
        .then((value) {
      const Duration(seconds: 2);
      // ReloadData();
    });
  }

// Flutter will use the fullscreenDialog property to change the animation
// and the app bar's left icon to an X instead of an arrow.
  PageRoute<T> _buildAdaptivePageRoute<T>({
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
  }) =>
      Platform.isAndroid
          ? MaterialPageRoute(
              builder: builder,
              fullscreenDialog: fullscreenDialog,
            )
          : CupertinoPageRoute(
              builder: builder,
              fullscreenDialog: fullscreenDialog,
            );
}
