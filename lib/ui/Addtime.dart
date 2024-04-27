import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/Addmedicine.dart';
import 'package:flutter_application_1/ui/Home.dart';
import 'package:flutter_application_1/ui/freq.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../arm/local_notifications.dart';

class Addtime extends StatefulWidget {
  final String nameMedicine;
  final String medicineQuantity;
  final String selectedDropdownValue;
  final String startDate;
  final String endDate;
  const Addtime(
      {Key? key,
      required this.nameMedicine,
      required this.medicineQuantity,
      required this.selectedDropdownValue,
      required this.startDate,
      required this.endDate})
      : super(key: key);

  @override
  State<Addtime> createState() => _AddtimeState();
}

class _AddtimeState extends State<Addtime> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }

  TimeOfDay selectedTime = TimeOfDay.now();
  List<TimeOfDay> selectedTimes = [];
  int generateRandomInt() {
    var random = Random();
    return random.nextInt(10001); // สุ่มจำนวนเต็มระหว่าง 0 ถึง 10000
  }

  Future<void> saveDataToFirebase() async {
    CollectionReference medications = _firestore.collection('medicine');
    List<String> timesList = selectedTimes.map((time) {
      // Convert TimeOfDay to a string representation of time (HH:mm)
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }).toList();
    // ตัวที่เพิ่มเข้ามา Arm
    DateTime dateTime = DateFormat("dd/MM/yyyy").parse(widget.startDate);
    DateTime dateTimeend = DateFormat("dd/MM/yyyy").parse(widget.endDate);
    // int day = dateTime.day;
    // int month = dateTime.month;
    // int year = dateTime.year;
    DateTime startDate = dateTime; // เริ่มต้นวันที่
    DateTime endDate = dateTimeend; // สิ้นสุดวันที่
    int number = 1;
    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(Duration(days: 1))) {
        print(number);
        number +=1;
      for (String time in timesList) {
        List<String> timeParts = time.split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        print("${date.day} ${date.month} ${date.year} ${hour} ${minute}");
        await LocalNotifications.showScheduleNotification(
          id: generateRandomInt(),
          title: "แจ้งเตือน",
          body:
              "ชื่อ${widget.nameMedicine} ทานต่อครั้ง${widget.medicineQuantity} หน่วยยา ${widget.selectedDropdownValue}",
          payload: "test 1",
          day: date.day,
          month: date.month,
          year: date.year,
          hour: hour,
          minute: minute,
        );
      }
    }
    
    var uuid = Uuid().v4();
    Map<String, dynamic> documentData = {
      'id': uuid,
      'ชื่อยา': widget.nameMedicine,
      'ปริมาณยาที่ทานต่อครั้ง': widget.medicineQuantity,
      'หน่วยยา': widget.selectedDropdownValue,
      'วันที่เริ่มทาน': widget.startDate,
      'วันสุดท้ายที่ทาน': widget.endDate,
      'เวลาแจ้งเตือน': timesList,
      'สถานะ': List.filled(number-1, 'ว่าง')
    };
    try {
     
      await medications.doc(uuid).set(documentData);
      // await medications.add(documentData);
      print('Data added to Firestore successfully!');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('คุณต้องการรับแจ้งเตือนกี่โมง',
            style: TextStyle(
                fontFamily: 'SukhumvitSet-Bold',
                fontSize: 24,
                fontWeight: FontWeight.w500)),
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
        leading: IconButton(
          icon: const ImageIcon(
            AssetImage("assets/images/arrow_left.png"),
            size: 40,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.only(top: 25)),
            const Text(
              'เวลาแจ้งเตือน',
              style: TextStyle(fontSize: 24, fontFamily: "SukhumvitSet-Medium"),
            ),
            // Text('ชื่อยา: ${widget.nameMedicine}'),
            // Text('ปริมาณยา: ${widget.medicineQuantity}'),
            //  Text('หน่วย: ${widget.selectedDropdownValue}'),
            for (int index = 0; index < selectedTimes.length; index++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTimes[index],
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null && pickedTime.minute <= 59) {
                        setState(() {
                          selectedTimes[index] = pickedTime;
                        });
                      }
                    },
                    child: Container(
                      width: 130,
                      height: 65,
                      padding: const EdgeInsets.fromLTRB(21, 8, 2, 5),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${selectedTimes[index].hour} : ${selectedTimes[index].minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontFamily: "SukhumvitSet-Bold",
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        selectedTimes.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTimes.add(pickedTime);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color.fromARGB(255, 128, 202, 255)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add,
                        color: Colors.white), // Add the desired icon
                    SizedBox(
                        width:
                            10), // Adjust the spacing between the icon and text
                    Text(
                      'ตั้งเวลาแจ้งเตือน',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: "SukhumvitSet-Medium",
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

/////////////////////ย้อนกลับ-ตกลง/////////////////////////////////
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 60,
        margin: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(right: 5),
                width: double.maxFinite,
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.only(
                          left: 5, right: 5, top: 10, bottom: 10),
                    ),
                    shape: MaterialStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            )),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => const Color.fromRGBO(88, 135, 255, 1)),
                    elevation: MaterialStateProperty.resolveWith<double>(
                      (Set<MaterialState> states) {
                        return 2.0;
                      },
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ย้อนกลับ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'SukhumvitSet-Bold'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(left: 5),
                width: double.maxFinite,
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.only(
                          left: 5, right: 5, top: 10, bottom: 10),
                    ),
                    shape: MaterialStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            )),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => const Color.fromRGBO(88, 135, 255, 1)),
                    elevation: MaterialStateProperty.resolveWith<double>(
                      (Set<MaterialState> states) {
                        return 2.0;
                      },
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Home()));
                    await saveDataToFirebase();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ตกลง",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'SukhumvitSet-Bold'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
