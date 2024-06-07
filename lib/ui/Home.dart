import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/listmedicine.dart';
import 'package:flutter_application_1/menu/menulist.dart';
import 'package:flutter_application_1/test.dart';
import 'package:flutter_application_1/ui/Addmedicine.dart';
import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:intl/intl.dart';

import '../noti/local_notifications.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ตัวควบคุมการเลือก ListView ตามแจ้งเตือน
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  int indexNotiDate = 0;

  // List of icons for the bottom navigation bar
  static const List<Map<String, dynamic>> _icons = [
    {"icon": Icons.medication, "label": "ยา", "page": listmedicine()},
    {"icon": Icons.home, "label": "หน้าลัก", "page": Home()},
    {"icon": Icons.menu, "label": "เมนู", "page": menulist()},
  ];
  // ฟังชันควบคุมแจ้งเตือน

  // Function to handle item tap in bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate to the selected page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _icons[index]["page"]),
      ).then((_) {
        // รีเซ็ตการสมัครรับการแจ้งเตือนเมื่อกลับมาที่หน้าเดิม

        _scrollToNotification(0);
      });
      setState(() {
        _notificationSubscription?.cancel();
      });
      // ยกเลิกการสมัครรับการแจ้งเตือนเมื่อไปยังหน้าอื่น
    });
  }

  final Stream<QuerySnapshot> user =
      FirebaseFirestore.instance.collection('medicine').snapshots();

  var dateOutputDate = DateTime.now();
  StreamSubscription? _notificationSubscription;
  var selectedDate = "";
  Future<void> saveDataToFirebase(
      {required String id, required List<List<String>> state}) async {
    // final reference = FirebaseFirestore.instance.doc('products/${id}');
    String listToString1 = jsonEncode(state);
    CollectionReference medications =
        FirebaseFirestore.instance.collection('medicine');
    Map<String, dynamic> documentData = {'สถานะ': listToString1};
    try {
      // await reference.set(documentData);

      await medications.doc(id).update(documentData);
      print('Data added to Firestore successfully!');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<void> savetimeToFirebase(
      {required String id, required List<List<String>> time}) async {
    // final reference = FirebaseFirestore.instance.doc('products/${id}');
    String listToString1 = jsonEncode(time);
    CollectionReference medications =
        FirebaseFirestore.instance.collection('medicine');
    Map<String, dynamic> documentData = {'เวลาคลิก': listToString1};
    try {
      // await reference.set(documentData);

      await medications.doc(id).update(documentData);
      print('Data added to Firestore successfully!');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<String> fetchData() async {
    CollectionReference medications =
        FirebaseFirestore.instance.collection('name');

    try {
      // ดึงเอกสารและรอการเสร็จสิ้น
      DocumentSnapshot snapshot =
          await medications.doc("hzjqFYmp7ywHhSLMDlxN").get();

      if (snapshot.exists) {
        // แปลงข้อมูลจากเอกสารเป็น Map และเข้าถึงฟิลด์ที่ต้องการ
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['name']; // สมมติว่า 'name' คือชื่อฟิลด์ที่คุณต้องการ
      } else {
        return "กรุณาเพิ่มชื่อ-นามสกุล";
      }
    } catch (e) {
      // จัดการกับข้อผิดพลาดที่อาจเกิดขึ้น
      return "Error fetching data: $e";
    }
  }

  Future<void> updateAllMatchingDocuments(
      {required String newStatus,
      required String newTime,
      required String selectTime}) async {
    // newStatus สถาณะที่ต้องการเปลียน
    // dateTime วันที่เลือก
    final collection = FirebaseFirestore.instance.collection('medicine');
    final snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      List<List<String>> stateTime = List<List<String>>.from(
          jsonDecode(doc['สถานะ']).map((list) => List<String>.from(list)));
      List<List<String>> timeList = List<List<String>>.from(
          jsonDecode(doc['เวลาคลิก']).map((list) => List<String>.from(list)));
      DateTime startDate =
          DateFormat("dd/MM/yyyy").parse(doc['วันที่เริ่มทาน']);
      DateTime endDate =
          DateFormat("dd/MM/yyyy").parse(doc['วันสุดท้ายที่ทาน']);

      List<dynamic> notificationTimes = doc['เวลาแจ้งเตือน'];

      DateTime dateTime = DateFormat("dd/M/yyyy HH:mm").parse(selectTime);
      int indexDateInt = 0;
      bool swidt = false;
      for (DateTime date = startDate;
          date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
          date = date.add(Duration(days: 1))) {
        int indexDayInt = 0;
        // แสดงผลหรือทำงานกับวันที่
        for (String timeNoti in notificationTimes) {
          DateTime indateTime = DateFormat("dd/M/yyyy HH:mm")
              .parse("${date.day}/${date.month}/${date.year} $timeNoti");
          // เอาวันที่ที่มาจากการกดปุ่มมา loopเปลียบเทียบกับ เวลาใน firebase
          if (dateTime.year == indateTime.year &&
              dateTime.month == indateTime.month &&
              dateTime.day == indateTime.day &&
              dateTime.hour == indateTime.hour &&
              dateTime.minute == indateTime.minute) {
            // ป้องกันการบันทึกซ้ำในรายการที่กดไปแล้ว
            if (stateTime[indexDateInt][indexDayInt] == "ว่าง") {
              // กำหนดค่าใหม่เมื่อตรงกับเงื่อนไข
              stateTime[indexDateInt][indexDayInt] = newStatus;
              timeList[indexDateInt][indexDayInt] = newTime;
              swidt = true;
            }
          }
          indexDayInt += 1;
        }
        indexDateInt += 1;
      }
      if (swidt) {
        await saveDataToFirebase(
          id: "${doc["id"]}",
          state: stateTime,
        );
        await savetimeToFirebase(
          id: "${doc["id"]}",
          time: timeList,
        );
        swidt = false;
      }
    }
  }


  // หา index ที่ตรงกับ id notification ฟังชันนี้มันเข้ามา 2 ครั้ง
  processDataNoti(String indexPayload) async {
    final collection = FirebaseFirestore.instance.collection('medicine');
    final snapshot = await collection.get();

    Map<String, List<Map<String, String>>> dateToMembersMap = {};

    for (var doc in snapshot.docs) {
      DateTime _startDate =
          DateFormat("dd/MM/yyyy").parse(doc['วันที่เริ่มทาน']);
      DateTime _endDate =
          DateFormat("dd/MM/yyyy").parse(doc['วันสุดท้ายที่ทาน']);
      List<List<String>> idNotificationList = List<List<String>>.from(
          jsonDecode(doc['id แจ้งเตือน'])
              .map((list) => List<String>.from(list)));

      int index = 0; // ใช้เพื่อติดตาม id แจ้งเตือนในแต่ละวัน
      for (DateTime date = _startDate;
          date.isBefore(_endDate) || date.isAtSameMomentAs(_endDate);
          date = date.add(Duration(days: 1))) {
        String dateKey = DateFormat("dd/MM/yyyy").format(date);

        // ตรวจสอบว่า key นี้มีอยู่ใน Map หรือยัง ถ้าไม่มีก็สร้างรายการใหม่
        if (!dateToMembersMap.containsKey(dateKey)) {
          dateToMembersMap[dateKey] = [];
        }

        // เพิ่ม id แจ้งเตือนที่ตรงกับวันที่นั้นลงในรายการ
        if (index < idNotificationList.length) {
          for (String id in idNotificationList[index]) {
            dateToMembersMap[dateKey]?.add({"id": id});
          }
        }

        index++;
      }
    }

    // ค้นหา indexPayload ใน Members
    for (var dateKey in dateToMembersMap.keys) {
      var members = dateToMembersMap[dateKey];
      for (int i = 0; i < members!.length; i++) {
        if (members[i]['id'] == indexPayload) {
          DateTime _indexDate =
                DateFormat("dd/MM/yyyy").parse(dateKey);
          int daysDifference = _indexDate.difference(dateOutputDate).inDays;
          return {'indexDate': daysDifference, 'indexTime': i};
        }
      }
    }

    // กรณีที่หาไม่เจอ
    return {'indexDate': 0, 'indexTime': 0};
  }

  // ควบคุมการเลื่อน
  void _scrollToNotification(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          index * 200.0, // Adjust this value based on your item height
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
    // เมื่อเลื่อนเสร็จให้ยกเลิกแจ้งเตือนโดยทันที
    _notificationSubscription?.cancel();
  }

  _subscribeToNotifications() async {
    _notificationSubscription =
        LocalNotifications.onClickNotification.listen((payload) async {

      Map<String, int> result = await processDataNoti(payload);
      indexNotiDate = result['indexDate']!;
      int indexTime = result['indexTime']!;
      _scrollToNotification(indexTime);
      setState(() {
        dateOutputDate = dateOutputDate.add(Duration(days: indexNotiDate));
      });

    });
  }

  void _initializeNotifications() async {
    await _subscribeToNotifications();
  }

  // ดึงเพื่อค้นหารายการ noti ที่ต้องการ
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeNotifications();
  }

  // เพื่อปิดการใช้งานที่ค้างอยู่ใน LocalNotifications
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
        title: FutureBuilder<String>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator()); // แสดงสัญญาณการโหลด
              } else if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              } else {
                return Text(
                  '${snapshot.data}',
                  style: TextStyle(fontSize: 24),
                ); // แสดงข้อมูลที่ได้รับ
              }
            }),
        leading: const Icon(
          Icons.person,
          size: 35,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 35,
            ), // ไอคอนเพิ่มยา
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Addmedicine()),
              );
              _notificationSubscription?.cancel();
              _scrollToNotification(0);
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              height: 150,
              child: EventCalendar(
                dateTime: CalendarDateTime(
                  year: dateOutputDate.year,
                  month: dateOutputDate.month,
                  day: dateOutputDate.day,
                  calendarType: CalendarType.GREGORIAN,
                ),
                calendarOptions: CalendarOptions(
                    toggleViewType: false, viewType: ViewType.DAILY),
                dayOptions: DayOptions(
                  compactMode: false,
                  dayFontSize: 16.0,
                  disableFadeEffect: true,
                  weekDaySelectedColor: Colors.black,
                  selectedTextColor: Colors.black,
                  selectedBackgroundColor:
                      const Color.fromRGBO(141, 206, 254, 1.0),
                ),
                headerOptions: HeaderOptions(
                    weekDayStringType: WeekDayStringTypes.SHORT,
                    monthStringType: MonthStringTypes.FULL,
                    headerTextColor: Colors.black),
                calendarType: CalendarType.GREGORIAN,
                calendarLanguage: 'th',
                onInit: () {
                  DateTime dateTemp = DateTime(dateOutputDate.year,
                      dateOutputDate.month, dateOutputDate.day, 0, 0);
                  var sDate =
                      DateFormat('yyyy-MM-dd').format(dateTemp).toString();
                  selectedDate = sDate;
                  var inputFormat = DateFormat('yyyy-MM-dd');
                  dateOutputDate =
                      inputFormat.parse(selectedDate); // <-- dd/MM 24H format
                  //loadDataMedicineToDay
                  (selectedDate);
                },
                onDateTimeReset: (date) {
                  setState(() {
                    DateTime dateTemp =
                        DateTime(date.year, date.month, date.day, 0, 0);
                    var sDate =
                        DateFormat('yyyy-MM-dd').format(dateTemp).toString();
                    selectedDate = sDate;
                    var inputFormat = DateFormat('yyyy-MM-dd');
                    dateOutputDate = inputFormat.parse(selectedDate);
                  });
                },
                onChangeDateTime: (date) {
                  setState(() {
                    DateTime dateTemp =
                        DateTime(date.year, date.month, date.day, 0, 0);
                    var sDate =
                        DateFormat('yyyy-MM-dd').format(dateTemp).toString();
                    selectedDate = sDate;
                    var inputFormat = DateFormat('yyyy-MM-dd');
                    dateOutputDate = inputFormat.parse(selectedDate);
                  });
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(88, 135, 255, 1),
                  borderRadius: BorderRadius.circular(25.0)),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(DateFormat.yMMMd().format(dateOutputDate).toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontFamily: 'SukhumvitSet-Bold'),
                  textAlign: TextAlign.center),
            ),
            Expanded(
              child: Container(
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
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        DateTime startDateTime = DateFormat("dd/MM/yyyy")
                            .parse(data.docs[index]['วันที่เริ่มทาน']);
                        DateTime endDateTime = DateFormat("dd/MM/yyyy")
                            .parse(data.docs[index]['วันสุดท้ายที่ทาน']);

                        DateTime selectDateTime = DateTime(dateOutputDate.year,
                            dateOutputDate.month, dateOutputDate.day);
                        int allday = dateOutputDate.day - startDateTime.day;
                        // print(
                        //     "000 ${selectDateTime.year} ${dateOutputDate.month} ${dateOutputDate.day}");
                        if ((selectDateTime.isAfter(startDateTime) ||
                                selectDateTime
                                    .isAtSameMomentAs(startDateTime)) &&
                            (selectDateTime.isBefore(endDateTime) ||
                                selectDateTime.isAtSameMomentAs(endDateTime))) {
                          // print("อยู่ในช่วง");

                          List<List<String>> stateTime =
                              List<List<String>>.from(
                                  jsonDecode(data.docs[index]['สถานะ'])
                                      .map((list) => List<String>.from(list)));
                          List<List<String>> timeList = List<List<String>>.from(
                              jsonDecode(data.docs[index]['เวลาคลิก'])
                                  .map((list) => List<String>.from(list)));

                          List<List<String>> idNotiList =
                              List<List<String>>.from(
                                  jsonDecode(data.docs[index]['id แจ้งเตือน'])
                                      .map((list) => List<String>.from(list)));
                          // print("iiiiii${stateTime}");
                          // for (int number = 0;number < data.docs[index]['เวลาแจ้งเตือน'].length;number++)
                          // print(
                          //     "88888/${data.docs[index]['เวลาแจ้งเตือน'].length}");
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  data.docs[index]['เวลาแจ้งเตือน'].length,
                              itemBuilder: (context, number) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            '${data.docs[index]['ชื่อยา']} ${data.docs[index]['ปริมาณยาที่ทานต่อครั้ง']} ${data.docs[index]['หน่วยยา']} ',
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              10), // เพิ่ม padding รอบ Text
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 5, 0),
                                                child: Text(
                                                  'เวลาทานยา:',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    'ครั้งที่ ${number + 1} เวลา ${data.docs[index]['เวลาแจ้งเตือน'][number]}',
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            '${stateTime[allday][number] == "ว่าง" ? "" : "ทานยา: ${stateTime[allday][number]}"}',
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: stateTime[allday]
                                                          [number] ==
                                                      "ไม่รับยา"
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                        ),
                                        '${stateTime[allday][number]}' == "ว่าง"
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(5, 0, 5, 0),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                        onPressed: () async {
                                                          var timeNow =
                                                              DateTime.now();
                                                          stateTime[allday]
                                                                  [number] =
                                                              "ทานยาแล้ว";
                                                          timeList[allday]
                                                                  [number] =
                                                              "${timeNow.day}/${timeNow.month}/${timeNow.year} ${timeNow.hour}:${timeNow.minute}";
                                                          await updateAllMatchingDocuments(
                                                            newStatus:
                                                                "ทานยาแล้ว",
                                                            newTime:
                                                                timeList[allday]
                                                                    [number],
                                                            selectTime:
                                                                "${selectDateTime.day}/${selectDateTime.month}/${selectDateTime.year} ${data.docs[index]['เวลาแจ้งเตือน'][number]}",
                                                          );
                                                          LocalNotifications
                                                              .cancelNotificationById(
                                                                  int.parse(idNotiList[
                                                                          allday]
                                                                      [
                                                                      number]));
                                                          // await saveDataToFirebase(
                                                          //   id: "${data.docs[index]['id']}",
                                                          //   state: stateTime,
                                                          // );
                                                          // await savetimeToFirebase(
                                                          //   id: "${data.docs[index]['id']}",
                                                          //   time: timeList,
                                                          // );
                                                        },
                                                        child: const Text(
                                                          "รับยา",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(5, 0, 5, 0),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor: Colors
                                                              .red, // เปลี่ยนสีเป็นสีแดง
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                        onPressed: () async {
                                                          var timeNow =
                                                              DateTime.now();
                                                          stateTime[allday]
                                                                  [number] =
                                                              "ไม่รับยา"; // กำหนดสถานะเป็น "ไม่รับยา"
                                                          timeList[allday]
                                                                  [number] =
                                                              "${timeNow.day}/${timeNow.month}/${timeNow.year} ${timeNow.hour}:${timeNow.minute}";
                                                          await updateAllMatchingDocuments(
                                                            newStatus:
                                                                "ไม่รับยา",
                                                            newTime:
                                                                timeList[allday]
                                                                    [number],
                                                            selectTime:
                                                                "${selectDateTime.day}/${selectDateTime.month}/${selectDateTime.year} ${data.docs[index]['เวลาแจ้งเตือน'][number]}",
                                                          );
                                                          LocalNotifications
                                                              .cancelNotificationById(
                                                                  int.parse(idNotiList[
                                                                          allday]
                                                                      [
                                                                      number]));
                                                        },
                                                        child: const Text(
                                                          "ไม่รับยา", // แสดงข้อความ "ไม่รับยา"
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                        return Container();
                      },
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // await LocalNotifications.printPendingNotifications();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Addmedicine()),
                );
                _scrollToNotification(0);
                setState(() {
                  _notificationSubscription?.cancel();
                });
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                elevation: 15.0,
                minimumSize: const Size(50, 50),
              ),
              child: const Text('เพิ่มยา'),
            ),
            const SizedBox(
              height: 15,
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _icons
            .asMap()
            .entries
            .map((MapEntry<int, Map<String, dynamic>> entry) {
          return BottomNavigationBarItem(
            icon: Icon(
              entry.value["icon"],
              size: 60,
              color: const Color.fromARGB(255, 72, 71, 71),
            ),
            // Icon size
            label: entry.value["label"],
          );
        }).toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
