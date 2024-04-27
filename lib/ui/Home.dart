import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/listmedicine.dart';
import 'package:flutter_application_1/menu/menulist.dart';
import 'package:flutter_application_1/test.dart';
import 'package:flutter_application_1/ui/Addmedicine.dart';
import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  // List of icons for the bottom navigation bar
  static const List<Map<String, dynamic>> _icons = [
    {"icon": Icons.medication, "label": "ยา", "page": listmedicine()},
    {"icon": Icons.home, "label": "หน้าลัก", "page": Home()},
    {"icon": Icons.menu, "label": "เมนู", "page": menulist()},
  ];

  // Function to handle item tap in bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate to the selected page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _icons[index]["page"]),
      );
    });
  }

  final Stream<QuerySnapshot> user =
      FirebaseFirestore.instance.collection('medicine').snapshots();

  var dateOutputDate = DateTime.now();
  var selectedDate = "";
  Future<void> saveDataToFirebase({required String id,required List<dynamic> state}) async {
    // final reference = FirebaseFirestore.instance.doc('products/${id}');
    CollectionReference medications = FirebaseFirestore.instance.collection('medicine');
    Map<String, dynamic> documentData = {
      'สถานะ': state
    };
    try {
      // await reference.set(documentData);

      await medications.doc(id).update(documentData);
      print('Data added to Firestore successfully!');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
        title: const Text(
          'ชื่อ-นามสกุล',
          style: TextStyle(fontSize: 24),
        ),
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
                calendarLanguage: 'en',
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
                    if (data.size == 0) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'คุณยังไม่มีรายการแจ้งเตือน',
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        DateTime startDateTime = DateFormat("dd/MM/yyyy")
                            .parse(data.docs[index]['วันที่เริ่มทาน']);
                        DateTime endDateTime = DateFormat("dd/MM/yyyy")
                            .parse(data.docs[index]['วันสุดท้ายที่ทาน']);
                        
                        DateTime selectDateTime = DateTime(dateOutputDate.year,
                            dateOutputDate.month, dateOutputDate.day);
                        int allday =  dateOutputDate.day - startDateTime.day;
                        print(
                            "000 ${selectDateTime.year} ${dateOutputDate.month} ${dateOutputDate.day}");
                        if ((selectDateTime.isAfter(startDateTime) ||
                                selectDateTime
                                    .isAtSameMomentAs(startDateTime)) &&
                            (selectDateTime.isBefore(endDateTime) ||
                                selectDateTime.isAtSameMomentAs(endDateTime))) {
                          print("อยู่ในช่วง");
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      '${data.docs[index]['ชื่อยา']} ${data.docs[index]['ปริมาณยาที่ทานต่อครั้ง']} ${data.docs[index]['หน่วยยา']} ',
                                      style: const TextStyle(fontSize: 24),
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
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 0),
                                          child: Text(
                                            'เวลาทานยา:',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            for (int number = 0;
                                                number <
                                                    data
                                                        .docs[index]
                                                            ['เวลาแจ้งเตือน']
                                                        .length;
                                                number++)
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
                                      '${data.docs[index]['สถานะ'][allday] == "ว่าง" ? "" : "ทานยา: ${data.docs[index]['สถานะ'][allday]}"}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  '${data.docs[index]['สถานะ'][allday]}' == "ว่าง"? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white),
                                              onPressed: () async {
                                                List<dynamic> datastatus = data.docs[index]['สถานะ'];
                                                datastatus[allday] = "ทานยาแล้ว";
                                                await saveDataToFirebase(id:"${data.docs[index]['id']}",state: datastatus);

                                              },
                                              child: Text("รับยา",style:
                                                const TextStyle(fontSize: 18))),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white),
                                              onPressed: () async {
                                                List<dynamic> datastatus = data.docs[index]['สถานะ'];
                                                datastatus[allday] = "ปฏิเสธการทานยา";
                                                await saveDataToFirebase(id:"${data.docs[index]['id']}",state: datastatus);
                                              },
                                              child: Text("ปฏิเสธ",style:
                                                const TextStyle(fontSize: 18))),
                                        ),
                                      ),
                                    ],
                                  ) : Container(),
                                ],
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Addmedicine()),
                );
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
