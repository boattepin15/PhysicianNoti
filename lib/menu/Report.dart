import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/menu/menulist.dart';
import 'package:intl/intl.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final Stream<QuerySnapshot> user =
      FirebaseFirestore.instance.collection('medicine').snapshots();
  var dateOutputDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
        title: const Text('ประวัติการทานยา',
            style: TextStyle(
                fontFamily: 'SukhumvitSet-Bold',
                fontSize: 25,
                fontWeight: FontWeight.w500)),
        leadingWidth: 0,
        leading: Container(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.black,
              size: 40,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const menulist()));
            },
          ),
        ],
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: user,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading');
            }
            final data = snapshot.requireData;

            if (data.size == 0) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ไม่มีข้อมูล',
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Container(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ข้อมูลยา',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('เวลา',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('สถานะยา',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      List<List<String>> stateTime = List<List<String>>.from(
                          jsonDecode(data.docs[index]['สถานะ'])
                              .map((list) => List<String>.from(list)));
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: stateTime.length,
                          itemBuilder: (context, number) {
                            // /*-
                            DateTime startDateTime = DateFormat("dd/MM/yyyy")
                                .parse(data.docs[index]['วันที่เริ่มทาน']);

                            // คำนวนวันที่เอาไปแสดงเพราะไม่ได้เก็บใน database
                            DateTime newDateTime =
                                startDateTime.add(Duration(days: number));

                            return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: stateTime[number].length,
                                itemBuilder: (context, numberTime) {
                                  
                                  // print("sdfdsfadsfsfasf ${stateTime[number][numberTime]}");

                                  if (stateTime[number][numberTime] == "ว่าง") {
                                    return Container();
                                  }
                                  

                                  
                                  return Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${data.docs[index]['ชื่อยา']} ${data.docs[index]['ปริมาณยาที่ทานต่อครั้ง']} ${data.docs[index]['หน่วยยา']} ',
                                        style: const TextStyle(fontSize: 23),
                                      ),
                                      Text(
                                        // '${data.docs[index]['เวลาแจ้งเตือน'][allday]}',
                                        "${newDateTime.day}-${newDateTime.month}-${newDateTime.year} ${data.docs[index]['เวลาแจ้งเตือน'][numberTime]}",
                                        style: const TextStyle(fontSize: 23),
                                      ),
                                      Text(
                                        '${stateTime[number][numberTime]}',
                                        style: const TextStyle(fontSize: 23),
                                      ),
                                    ],
                                  );
                                });
                          });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
