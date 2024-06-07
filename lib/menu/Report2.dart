import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/menu/menulist.dart';
import 'package:intl/intl.dart';

class Report2 extends StatefulWidget {
  const Report2({super.key});

  @override
  State<Report2> createState() => _Report2State();
}

class _Report2State extends State<Report2> {
  final Stream<QuerySnapshot> user =
      FirebaseFirestore.instance.collection('medicine').snapshots();
  var dateOutputDate = DateTime.now();

  Map<String, bool> _expandedGroups = {};

  List<Map<String, dynamic>> manageData(List<QueryDocumentSnapshot> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var item in data) {
      String name = item["ชื่อยา"];
      List<dynamic> dateTimes = jsonDecode(item["เวลาคลิก"]);
      List<dynamic> statusesList = jsonDecode(item["สถานะ"]);

      // List<List<DateTime>> dateTimes = [];
      // for (int i = 0; i < dateTimesList.length; i++) {
      //   dateTimes.add([]);
      //   for (String date in dateTimesList[i]) {
      //     dateTimes[i].add(DateFormat("dd/MM/yyyy HH:mm").parse(date));
      //   }
      // }

      List<List<String>> statuses = [];
      List<Map<String, int>> indexDate = [];
      // ทำการกรองเพื่อหา index ที่มีทานยาแล้วเพื่อนำไปเก็บไว้ใช้กับการบันทึกลงข้อมูล
      for (int i = 0; i < statusesList.length; i++) {
        statuses.add([]);
        for (int a = 0; a < statusesList[i].length; a++) {
          statuses[i].add(statusesList[i][a]);
          if (statusesList[i][a] == "ทานยาแล้ว" || statusesList[i][a] == "ไม่รับยา") {
            indexDate.add({"i": i, "a": a});
          }
        }
      }

      // เช็คว่ามีชื่อยานี้ใน set หรือไม่ถ้าไม่มีก็กำหนดให้ชื่อนั้นเป็นค่าเริ่มต้น
      if (!groupedData.containsKey(name)) {
        groupedData[name] = [];
      }

      // เก็บประวัติไว้ในรายการตามชื่อยา
      for (Map<String, int> data in indexDate) {
        groupedData[name]!.add({
          "ชื่อยา": name,
          "สถานะ": statuses[data["i"]!][data["a"]!],
          "เวลาคลิก": dateTimes[data["i"]!][data["a"]!]
        });
      }
    }

    List<Map<String, dynamic>> result = [];

    groupedData.forEach((name, items) {
      // ทำการจัดเรียง วันเวลา จากเก่าไปใหม่
      for (int i = 0; i < items.length - 1; i++) {
        for (int j = 0; j < items.length - i - 1; j++) {
          // เป็นการตัวสอบวันที่ โดยมีการส่งค่า 3 ค่าคือ
          //-1 items[j]["เวลาคลิก"] มีค่าน้อยกว่า items[j + 1]["เวลาคลิก"]
          // 0 คือมีค่าเท่ากัน
          // 1 items[j]["เวลาคลิก"] มีค่ามากกว่า items[j + 1]["เวลาคลิก"]
          if (items[j]["เวลาคลิก"].compareTo(items[j + 1]["เวลาคลิก"]) >= 0) {
            // เก็บตัวแปรเดิมไว้
            var temp = items[j];
            // นำรายการ ที่เปลียบเทียบกับรายการข้องหน้าย้ายมา - 1 ตำแหน่ง
            items[j] = items[j + 1];
            // นำตำแหน่งปัจจุบันย้ายไป +1 ตำแหน่ง
            items[j + 1] = temp;
            // ถ้าให้อธิบายคือสลับตำแหน่งกัน
          }
        }
      }
      // นำผลลัพที่ได้หลังจากจัดเรียงมาเพิ่มเข้า result
      
      result.add({
        "ชื่อยา": name,
        "รายการ": items.map((item) {
          return {
            "ชื่อยา": item["ชื่อยา"],
            "สถานะ": item["สถานะ"],
            "เวลาคลิก": item["เวลาคลิก"],
          };
        }).toList(),
      });
    });

    return result;
  }
  // กำหนดจำนวนสูงสุดในการแสดงตัวอักษร
  String truncate(String text, int length) {
  if (text.length <= length) {
    return text;
  } else {
    return '${text.substring(0, length)}...';
  }
}

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
            final data = snapshot.requireData.docs;

            if (data.isEmpty) {
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

            var groupedData = manageData(data);

            return Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 120.0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "ชื่อยา",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160.0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "วัน-เวลาที่กดรับยา",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120.0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "สถาณะ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    children: groupedData.map<Widget>((group) {
                      bool isExpanded =
                          _expandedGroups[group['ชื่อยา']] ?? true;
                      print(groupedData);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "${truncate(group['ชื่อยา'],15)} (มี ${group['รายการ'].length} รายการ)",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down),
                                color: Colors.black,
                                iconSize: 24,
                                onPressed: () {
                                  setState(() {
                                    _expandedGroups[group['ชื่อยา']] =
                                        !isExpanded;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (isExpanded)
                            Column(
                              children: group['รายการ'].map<Widget>((item) {
                                // แยกส่วนของวันที่และเวลา
                                List<String> dateTimeParts = item["เวลาคลิก"].split(' ');
                                String datePart = dateTimeParts[0];
                                String timePart = dateTimeParts[1];
                                
                                // แยกวัน เดือน และปี
                                List<String> dateParts = datePart.split('/');
                                String day = dateParts[0].padLeft(2, '0');
                                String month = dateParts[1].padLeft(2, '0');
                                String year = dateParts[2];
                                
                                // แยกชั่วโมง และนาที
                                List<String> timeParts = timePart.split(':');
                                String hour = timeParts[0].padLeft(2, '0');
                                String minute = timeParts[1].padLeft(2, '0');
                                
                                // รวมกลับเป็น string เดียว
                                String formattedDateTimeStr = "$day/$month/$year $hour:$minute";
                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 120.0,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          truncate(item["ชื่อยา"],7),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 160.0,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          formattedDateTimeStr,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 120.0,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          item["สถานะ"],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    }).toList(),
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
