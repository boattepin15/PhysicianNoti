import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/menu/menulist.dart';
import 'package:flutter_application_1/screen/editmedicine.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:uuid/uuid.dart';

import 'noti/local_notifications.dart';

class listmedicine extends StatefulWidget {
  const listmedicine({super.key});

  @override
  State<listmedicine> createState() => _listmedicineState();
}

class _listmedicineState extends State<listmedicine> {
  final Stream<QuerySnapshot> user =
      FirebaseFirestore.instance.collection('medicine').snapshots();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 23/5/2567 เก็บที่แก้ไขชื่อยา
  List<TextEditingController> nameController = [];
  List<TextEditingController> amountController = [];
  List<TextEditingController> namDruguniteController = [];
  // เอาบันทึกค่าการเลือก start วันที่และ end วันที เมื่อกดเลือกวันที่จะถูกเอาไปใช้ในการส่งไป firebase
  TextEditingController dateStartController = TextEditingController();
  TextEditingController dateEndController = TextEditingController();

  // 23/5/2567 ใช้เก็บ รายการที่ดึงมาจาก firebase มาแสดง โดยมี จำนวนและชนิดยา
  List<String> amountDropdownValue = [];
  List<String> selectedDropdownValue = [];

  // 23/5/2567 เก็บแสดงหรือไม่แสดงแก้ไขบนหน้า UI
  List<bool> nameUI = [];
  List<bool> amountUI = [];
  List<bool> namDruguniteUI = [];

  // 23/5/2567 แก้ฟิว ชื่อยาใน firebase
  editText(String id, String input) async {
    CollectionReference names =
        FirebaseFirestore.instance.collection('medicine');
    names.doc(id).update({'ชื่อยา': input});
  }

  editamountText(String id, String input) async {
    CollectionReference names =
        FirebaseFirestore.instance.collection('medicine');
    names.doc(id).update({'ปริมาณยาที่ทานต่อครั้ง': input});
  }

  // 23/5/2567 แก้ฟิว ปริมาณยาที่ทานต่อครั้ง ใน firebase
  amountText(String id, int input) async {
    CollectionReference names =
        FirebaseFirestore.instance.collection('medicine');
    names.doc(id).update({
      'ปริมาณยาที่ทานต่อครั้ง': "$input",
    });
  }

  // 23/5/2567 แก้ฟิว หน่วยยา ใน firebase
  namDruguniteText(String id, String input) async {
    CollectionReference names =
        FirebaseFirestore.instance.collection('medicine');
    names.doc(id).update({
      'หน่วยยา': input,
    });
  }

  updateDateStart(String id, DateTime input) async {
    CollectionReference names =
        FirebaseFirestore.instance.collection('medicine');
    names.doc(id).update({
      'วันที่เริ่มทาน': "${input.day}/${input.month}/${input.year}",
    });
  }

  updateDateEnd(String id, String input) async {
    CollectionReference names =
        FirebaseFirestore.instance.collection('medicine');
    names.doc(id).update({
      'วันสุดท้ายที่ทาน': input,
    });
  }

  Future<DateTime?> datestart(BuildContext context, String _startDate) {
    Completer<DateTime?> completer = Completer<DateTime?>();

    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    Timer(const Duration(milliseconds: 400), () {
      int yearCurrent = DateTime.now().year + 1;
      showRoundedDatePicker(
        borderRadius: 25,
        styleDatePicker: MaterialRoundedDatePickerStyle(
          textStyleDayHeader: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color.fromRGBO(88, 135, 255, 1)),
          textStyleDayOnCalendar: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(88, 135, 255, 1)),
          paddingMonthHeader: const EdgeInsets.all(10),
          sizeArrow: 40,
          colorArrowPrevious: const Color.fromRGBO(88, 135, 255, 1),
          colorArrowNext: const Color.fromRGBO(88, 135, 255, 1),
          textStyleMonthYearHeader: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black),
          textStyleButtonPositive: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff8B939A)),
          textStyleButtonNegative: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff8B939A)),
        ),
        theme: ThemeData(
          primaryColor: const Color.fromRGBO(88, 135, 255, 1),
          hintColor: const Color.fromRGBO(88, 135, 255, 1),
          textTheme: const TextTheme(
            caption: TextStyle(
                fontFamily: 'SukhumvitSet-Bold',
                fontWeight: FontWeight.w500,
                color: Color(0xff8B939A)),
          ),
        ),
        era: EraMode.BUDDHIST_YEAR,
        context: context,
        height: 330,
        fontFamily: 'SukhumvitSet-Bold',
        locale: Locale("th", "TH"),
        initialDate: DateFormat("dd/MM/yyyy").parse(_startDate),
        firstDate: DateTime(1850),
        lastDate: DateTime(yearCurrent),
      ).then((date) {
        completer.complete(date);
      }).catchError((error) {
        completer.completeError(error);
      });
    });

    return completer.future;
  }

  Future<DateTime?> dateend(BuildContext context, String _endDate, String id) {
    Completer<DateTime?> completer = Completer<DateTime?>();

    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    Timer(const Duration(milliseconds: 400), () {
      int yearCurrent = DateTime.now().year + 1;
      showRoundedDatePicker(
        borderRadius: 25,
        styleDatePicker: MaterialRoundedDatePickerStyle(
          textStyleDayHeader: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color.fromRGBO(88, 135, 255, 1)),
          textStyleDayOnCalendar: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(88, 135, 255, 1)),
          paddingMonthHeader: const EdgeInsets.all(10),
          sizeArrow: 40,
          colorArrowPrevious: const Color.fromRGBO(88, 135, 255, 1),
          colorArrowNext: const Color.fromRGBO(88, 135, 255, 1),
          textStyleMonthYearHeader: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black),
          textStyleButtonPositive: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff8B939A)),
          textStyleButtonNegative: const TextStyle(
              fontFamily: 'SukhumvitSet-Bold',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff8B939A)),
        ),
        theme: ThemeData(
          primaryColor: const Color.fromRGBO(88, 135, 255, 1),
          hintColor: const Color.fromRGBO(88, 135, 255, 1),
          textTheme: const TextTheme(
            caption: TextStyle(
                fontFamily: 'SukhumvitSet-Bold',
                fontWeight: FontWeight.w500,
                color: Color(0xff8B939A)),
          ),
        ),
        era: EraMode.BUDDHIST_YEAR,
        context: context,
        height: 330,
        fontFamily: 'SukhumvitSet-Bold',
        locale: Locale("th", "TH"),
        initialDate: DateFormat("dd/MM/yyyy").parse(_endDate),
        firstDate: DateTime(1850),
        lastDate: DateTime(yearCurrent),
      ).then((date) {
        completer.complete(date);
      }).catchError((error) {
        completer.completeError(error);
      });
    });

    return completer.future;
  }

  // แรนดอม id เมื่อสร้างนอกข้อเขตวันที่ที่กำหนด
  int generateRandomInt() {
    var random = Random();
    return random.nextInt(1000000); // สุ่มจำนวนเต็มระหว่าง 0 ถึง 10000
  }

  // หาเงื่อนไขว่าอยู่ในช่วงหรือไม่ระหว่าง startDate endDate SelectDate
  bool isDateInRange({
    required DateTime startDate2,
    required DateTime endDate2,
    required DateTime selectDate,
  }) {
    return selectDate.isAfter(startDate2) && selectDate.isBefore(endDate2) ||
        selectDate.isAtSameMomentAs(startDate2) ||
        selectDate.isAtSameMomentAs(endDate2);
  }

  updateDateStartNoti({
    required String id,
    required DateTime startDate2,
    required DateTime endDate2,
    required DateTime selectDate,
    required List<List<String>> idNoti,
    required List<List<String>> status,
    required List<List<String>> statusclick,
    required List<dynamic> noitText,
    required String name,
    required String amount,
    required String unit,
  }) async {
    CollectionReference notiIDDateState =
        FirebaseFirestore.instance.collection('medicine');
    // เช็คว่าวันที่ที่เลือกผ่านหน้าจออยู่ระหว่าง startDate กับ endDate หรือไม่
    if (isDateInRange(
      startDate2: startDate2,
      endDate2: endDate2,
      selectDate: selectDate,
    )) {
      print('selectDate อยู่ในช่วงเวลาระหว่าง startDate2 กับ endDate2');
      // หาความหาละหว่างวันที่เอาไปใช้ในการจัดการ statsu หรือ สถานะ
      int differenceInDays = selectDate.difference(startDate2).inDays;
      for (int i = 0; i < idNoti.length; i++) {
        for (String timeID in idNoti[i]) {
          // ยกเลิกแจ้งเตือนผ่านหน้าแอปทั้งหมดที่เกี่ยวข้องกับการแก้ไขโดยใช้ id
          LocalNotifications.cancelNotificationById(int.parse(timeID));
        }
      }
      for (int i = 0; i < differenceInDays; i++) {
        idNoti.removeAt(0);
        status.removeAt(0);
        statusclick.removeAt(0);
      }
      // เหลือบันทึกลง noti ในเครื่อง
    } else {
      print('selectDate ไม่อยู่ในช่วงเวลาระหว่าง startDate2 กับ endDate2');
      int differenceInDays = startDate2.difference(selectDate).inDays;
      for (int i = 0; i < idNoti.length; i++) {
        for (String timeID in idNoti[i]) {
          LocalNotifications.cancelNotificationById(int.parse(timeID));
        }
      }
      for (int i = 0; i < differenceInDays; i++) {
        // สร้าง id ตามฟิว เวลาแจ้งเตือน
        idNoti.insert(
            0,
            List<String>.generate(
                noitText.length, (index) => generateRandomInt().toString()));
        status.insert(
            0, List<String>.generate(noitText.length, (index) => "ว่าง"));
        statusclick.insert(
            0, List<String>.generate(noitText.length, (index) => "ว่าง"));
      }
    }
    // update แจ้งเตื่อนลงเครื่อง
    int numberDate = 0;
    for (DateTime date = selectDate;
        date.isBefore(endDate2) || date.isAtSameMomentAs(endDate2);
        date = date.add(Duration(days: 1))) {
      for (int i = 0; i < noitText.length; i++) {
        List<String> timeParts = noitText[i].split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        await LocalNotifications.showScheduleNotification(
          id: int.parse(idNoti[numberDate][i]),
          title: "แจ้งเตือน",
          body: "ชื่อยา${name} ${amount} ${unit}",
          payload: "${idNoti[numberDate][i]}",
          day: date.day,
          month: date.month,
          year: date.year,
          hour: hour,
          minute: minute,
        );
      }
      numberDate += 1;
    }

    // update แจ้งเตื่อนลง firebase และใช้ jsonEncode เพราะต้องการเอา "" ไปด้วย
    notiIDDateState.doc(id).update({
      'วันที่เริ่มทาน':
          "${selectDate.day}/${selectDate.month}/${selectDate.year}",
      'สถานะ': jsonEncode(status),
      'id แจ้งเตือน': jsonEncode(idNoti),
      'เวลาคลิก': jsonEncode(statusclick)
    });
  }

  updateDateEndNoti({
    required String id,
    required DateTime startDate2,
    required DateTime endDate2,
    required DateTime selectDate,
    required List<List<String>> idNoti,
    required List<List<String>> status,
    required List<List<String>> statusclick,
    required List<dynamic> noitText,
    required String name,
    required String amount,
    required String unit,
  }) async {
    CollectionReference notiIDDateState =
        FirebaseFirestore.instance.collection('medicine');
    // เช็คว่าวันที่ที่เลือกผ่านหน้าจออยู่ระหว่าง startDate กับ endDate หรือไม่
    if (isDateInRange(
      startDate2: startDate2,
      endDate2: endDate2,
      selectDate: selectDate,
    )) {
      print('selectDate อยู่ในช่วงเวลาระหว่าง startDate2 กับ endDate2');
      // หาความหาละหว่างวันที่เอาไปใช้ในการจัดการ statsu หรือ สถานะ
      int differenceInDays = endDate2.difference(selectDate).inDays;

      for (int i = 0; i < idNoti.length; i++) {
        for (String timeID in idNoti[i]) {
          // ยกเลิกแจ้งเตือนผ่านหน้าแอปทั้งหมดที่เกี่ยวข้องกับการแก้ไขโดยใช้ id
          LocalNotifications.cancelNotificationById(int.parse(timeID));
        }
      }

      for (int i = 0; i < differenceInDays; i++) {
        idNoti.removeLast();
        status.removeLast();
        statusclick.removeLast();
      }
      // เหลือบันทึกลง noti ในเครื่อง
    } else {
      print('selectDate ไม่อยู่ในช่วงเวลาระหว่าง startDate2 กับ endDate2');
      int differenceInDays = selectDate.difference(endDate2).inDays;
      for (int i = 0; i < idNoti.length; i++) {
        for (String timeID in idNoti[i]) {
          LocalNotifications.cancelNotificationById(int.parse(timeID));
        }
      }
      for (int i = 0; i < differenceInDays; i++) {
        // สร้าง id ตามฟิว เวลาแจ้งเตือน
        idNoti.add(List<String>.generate(
            noitText.length, (index) => generateRandomInt().toString()));
        status.add(List<String>.generate(noitText.length, (index) => "ว่าง"));
        statusclick
            .add(List<String>.generate(noitText.length, (index) => "ว่าง"));
      }
    }
    // update แจ้งเตื่อนลงเครื่อง
    int numberDate1 = 0;
    for (DateTime date = selectDate;
        date.isBefore(startDate2) || date.isAtSameMomentAs(startDate2);
        date = date.add(Duration(days: 1))) {
      for (int i = 0; i < noitText.length; i++) {
        List<String> timeParts = noitText[i].split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        await LocalNotifications.showScheduleNotification(
          id: int.parse(idNoti[numberDate1][i]),
          title: "แจ้งเตือน",
          body: "ชื่อยา${name} ${amount} ${unit}",
          payload: "${idNoti[numberDate1][i]}",
          day: date.day,
          month: date.month,
          year: date.year,
          hour: hour,
          minute: minute,
        );
      }
      numberDate1 += 1;
    }

    // update แจ้งเตื่อนลง firebase และใช้ jsonEncode เพราะต้องการเอา "" ไปด้วย
    notiIDDateState.doc(id).update({
      'วันสุดท้ายที่ทาน':
          "${selectDate.day}/${selectDate.month}/${selectDate.year}",
      'สถานะ': jsonEncode(status),
      'id แจ้งเตือน': jsonEncode(idNoti),
      'เวลาคลิก': jsonEncode(statusclick)
    });
  }

  noti(String id, List<dynamic> input) async {
    CollectionReference names =
        FirebaseFirestore.instance.collection('medicine');
    names.doc(id).update({
      'เวลาแจ้งเตือน': input,
    });
  }

  Future<void> saveDateToFirebase(
      String id,
      String startDate1,
      String endDate1,
      String state,
      List<List<String>> notiID,
      String noitText,
      String name,
      String amount,
      String unit,
      TimeOfDay Selecttime,
      int _index) async {
    DateTime _startDate = DateFormat("dd/MM/yyyy").parse(
        startDate1); //แปลงค่าวันที่เริ่มต้นและสิ้นสุดให้อยู่ในรูปแบบDateTime
    DateTime _endDate = DateFormat("dd/MM/yyyy").parse(endDate1);
    // ใช้สำหรับลูกวันที่
    int number = 0;
    for (DateTime date = _startDate;
        date.isBefore(_endDate) || date.isAtSameMomentAs(_endDate);
        date = date.add(Duration(days: 1))) {
      await LocalNotifications.cancelNotificationById(
          int.parse(notiID[number][_index]));
      int idGen = int.parse(notiID[number][_index]);
      await LocalNotifications.showScheduleNotification(
        id: idGen,
        title: "แจ้งเตือน",
        body: "ชื่อยา$name $amount $unit",
        payload: "$idGen",
        day: date.day,
        month: date.month,
        year: date.year,
        hour: Selecttime.hour,
        minute: Selecttime.minute,
      );
      number += 1;
    }
  }

  Future<void> saveAllEditToFirebase(
      String id,
      String startDate1,
      String endDate1,
      List<List<String>> state,
      List<List<String>> notiID,
      List<String> noitText,
      String name,
      String amount,
      String unit,
      TimeOfDay Selecttime,
      int _index) async {
    DateTime _startDate = DateFormat("dd/MM/yyyy").parse(
        startDate1); //แปลงค่าวันที่เริ่มต้นและสิ้นสุดให้อยู่ในรูปแบบDateTime
    DateTime _endDate = DateFormat("dd/MM/yyyy").parse(endDate1);
    // ใช้สำหรับลูกวันที่
    int number = 0;
    for (DateTime date = _startDate;
        date.isBefore(_endDate) || date.isAtSameMomentAs(_endDate);
        date = date.add(Duration(days: 1))) {
      await LocalNotifications.cancelNotificationById(
          int.parse(notiID[number][_index]));
      int idGen = int.parse(notiID[number][_index]);
      await LocalNotifications.showScheduleNotification(
        id: idGen,
        title: "แจ้งเตือน",
        body: "ชื่อยา$name $amount $unit",
        payload: "$idGen",
        day: date.day,
        month: date.month,
        year: date.year,
        hour: Selecttime.hour,
        minute: Selecttime.minute,
      );
      number += 1;
    }
  }

  void _saveChanges(int index, DocumentSnapshot doc) async {
    if (nameController[index].text.isNotEmpty &&
        amountController[index].text.isNotEmpty) {
      if (doc['ชื่อยา'] != nameController[index].text) {
        await editText(doc['id'], nameController[index].text);
      }
      if (doc['ปริมาณยาที่ทานต่อครั้ง'] != amountController[index].text) {
        await editamountText(doc['id'], amountController[index].text);
      }
    }
    setState(() {
      nameUI[index] = false;
      amountUI[index] = false;
    });
  }

  void _cancelChanges(int index) {
    setState(() {
      nameUI[index] = false;
      amountUI[index] = false;
    });
  }

  // กำหนดจำนวนสูงสุดในการแสดงตัวอักษร
  String truncate(String text, int length) {
    if (text.length <= length) {
      return text;
    } else {
      return '${text.substring(0, length)}..';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 40,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('ข้อมูลยา',
            style: TextStyle(
                fontFamily: 'SukhumvitSet-Bold',
                fontSize: 22,
                fontWeight: FontWeight.w500)),
        actions: const [],
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
            return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                // 23/5/2567 จำเป็นต้องเพิ่มเข้าไปใน list เพื่อให้สามารถแก้ไขได้ภายหลังเพราะใช้ index ในการแก้ไขจึงจำเป็นต้องมีค่า
                nameController.add(TextEditingController());
                amountController.add(TextEditingController());
                namDruguniteController.add(TextEditingController());
                selectedDropdownValue.add(data.docs[index]['หน่วยยา']);
                amountDropdownValue
                    .add(data.docs[index]['ปริมาณยาที่ทานต่อครั้ง']);
                nameUI.add(false);
                amountUI.add(false);
                namDruguniteUI.add(false);
                nameController[index].text = data.docs[index]['ชื่อยา'];
                amountController[index].text =
                    data.docs[index]['ปริมาณยาที่ทานต่อครั้ง'];
                return GestureDetector(
                  onTap: () {
                    // showDetailDialog(context, data.docs[index]);
                  },
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Row(
                        children: [
                          nameUI[index] == false
                              ? InkWell(
                                  onTap: () async {
                                    setState(() {
                                      // สลับ ui ในการแสดงผล
                                      nameUI[index] = !nameUI[index];
                                    });
                                  },
                                  child: Text(
                                    truncate(
                                        '${data.docs[index]['ชื่อยา']}', 5),
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8, 0, 8, 0),
                                  child: SizedBox(
                                    width: 50.0,
                                    child: TextFormField(
                                      controller: nameController[index],
                                      autofocus: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'ชื่อยา',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          letterSpacing: 0,
                                        ),
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          letterSpacing: 0,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        letterSpacing: 0,
                                      ),
                                      onFieldSubmitted: (value) {
                                        _saveChanges(index, data.docs[index]);
                                      },
                                    ),
                                  ),
                                ),
                          amountUI[index] == false
                              ? InkWell(
                                  onTap: () async {
                                    setState(() {
                                      amountUI[index] = !amountUI[index];
                                    });
                                  },
                                  child: AutoSizeText(
                                      " ${data.docs[index]['ปริมาณยาที่ทานต่อครั้ง']} ",
                                      style: const TextStyle(fontSize: 22),
                                      minFontSize: 12,maxLines: 1,overflow: TextOverflow.ellipsis,),
                                )
                              : SizedBox(
                                  width: 30.0,
                                  child: TextFormField(
                                    controller: amountController[index],
                                    autofocus: true,
                                    obscureText: false,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'ชื่อยา',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        letterSpacing: 0,
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        letterSpacing: 0,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      letterSpacing: 0,
                                    ),
                                    onFieldSubmitted: (value) {
                                      _saveChanges(index, data.docs[index]);
                                    },
                                  ),
                                ),
                          namDruguniteUI[index] == false
                              ? InkWell(
                                  onTap: () async {
                                    setState(() {
                                      namDruguniteUI[index] =
                                          !namDruguniteUI[index];
                                    });
                                  },
                                  child: Text(" ${data.docs[index]['หน่วยยา']}",
                                      style: const TextStyle(fontSize: 22)),
                                )
                              : SizedBox(
                                  width: 110.0,
                                  height: 70.0,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDropdownValue[index],
                                    // value: 'เม็ด',
                                    style: TextStyle(
                                        fontFamily: 'SukhumvitSet-Medium',
                                        color: Colors.black,
                                        fontSize: 16.0),
                                    items: <String>[
                                      'เม็ด',
                                      'ช้อนชา',
                                      'ช้อนโต๊ะ'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) async {
                                      await namDruguniteText(
                                          data.docs[index]['id'],
                                          value ?? "เม็ด");
                                      setState(() {
                                        selectedDropdownValue[index] =
                                            value ?? "1";
                                        namDruguniteUI[index] =
                                            !namDruguniteUI[index];
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              10.0), // Adjust the border radius as needed
                                        ),
                                      ), // Change to the desired background color
                                    ),
                                  ),
                                )
                        ],
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  DateTime? resultSelect = await datestart(
                                      context,
                                      data.docs[index]['วันที่เริ่มทาน']);
                                  if (resultSelect != null) {
                                    DateTime strDayStart =
                                        DateFormat('dd/MM/yyyy').parse(
                                            "${data.docs[index]['วันที่เริ่มทาน']}");
                                    DateTime strDayEnd =
                                        DateFormat('dd/MM/yyyy').parse(
                                            "${data.docs[index]['วันสุดท้ายที่ทาน']}");
                                    List<List<String>> idNotiList = (jsonDecode(
                                            data.docs[index]
                                                ['id แจ้งเตือน']) as List)
                                        .map((e) => List<String>.from(e))
                                        .toList();
                                    List<List<String>> statueList =
                                        (jsonDecode(data.docs[index]['สถานะ'])
                                                as List)
                                            .map((e) => List<String>.from(e))
                                            .toList();
                                    List<List<String>> statusclick =
                                        (jsonDecode(data.docs[index]
                                                ['เวลาคลิก']) as List)
                                            .map((e) => List<String>.from(e))
                                            .toList();
                                    if (resultSelect.isBefore(strDayEnd) ||
                                        resultSelect
                                            .isAtSameMomentAs(strDayEnd)) {
                                      print(resultSelect);

                                      await updateDateStartNoti(
                                        id: data.docs[index]['id'],
                                        startDate2: strDayStart,
                                        endDate2: strDayEnd,
                                        selectDate: resultSelect,
                                        idNoti: idNotiList,
                                        status: statueList,
                                        statusclick: statusclick,
                                        noitText: data.docs[index]
                                            ['เวลาแจ้งเตือน'],
                                        name: data.docs[index]['ชื่อยา'],
                                        amount: data.docs[index]
                                            ['ปริมาณยาที่ทานต่อครั้ง'],
                                        unit: data.docs[index]['หน่วยยา'],
                                      );
                                    } else {
                                      print("ห้ามตั้งมากกว่า end Date");
                                    }
                                  }
                                },
                                child: Text(
                                  'เริ่มทาน ${data.docs[index]['วันที่เริ่มทาน']} ถึง ',
                                  style: TextStyle(
                                    fontSize: 12.0
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  DateTime? resultSelect = await dateend(
                                      context,
                                      data.docs[index]['วันสุดท้ายที่ทาน'],
                                      data.docs[index]['id']);

                                  if (resultSelect != null) {
                                    DateTime strDayStart =
                                        DateFormat('dd/MM/yyyy').parse(
                                            "${data.docs[index]['วันที่เริ่มทาน']}");
                                    DateTime strDayEnd =
                                        DateFormat('dd/MM/yyyy').parse(
                                            "${data.docs[index]['วันสุดท้ายที่ทาน']}");
                                    List<List<String>> idNotiList = (jsonDecode(
                                            data.docs[index]
                                                ['id แจ้งเตือน']) as List)
                                        .map((e) => List<String>.from(e))
                                        .toList();
                                    List<List<String>> statueList =
                                        (jsonDecode(data.docs[index]['สถานะ'])
                                                as List)
                                            .map((e) => List<String>.from(e))
                                            .toList();
                                    List<List<String>> statusclick =
                                        (jsonDecode(data.docs[index]
                                                ['เวลาคลิก']) as List)
                                            .map((e) => List<String>.from(e))
                                            .toList();
                                    if (resultSelect.isAfter(strDayStart) ||
                                        resultSelect
                                            .isAtSameMomentAs(strDayStart)) {
                                      print(resultSelect);

                                      await updateDateEndNoti(
                                        id: data.docs[index]['id'],
                                        startDate2: strDayStart,
                                        endDate2: strDayEnd,
                                        selectDate: resultSelect,
                                        idNoti: idNotiList,
                                        status: statueList,
                                        statusclick: statusclick,
                                        noitText: data.docs[index]
                                            ['เวลาแจ้งเตือน'],
                                        name: data.docs[index]['ชื่อยา'],
                                        amount: data.docs[index]
                                            ['ปริมาณยาที่ทานต่อครั้ง'],
                                        unit: data.docs[index]['หน่วยยา'],
                                      );
                                    } else {
                                      print("ห้ามตั้งน้อยกว่า start Date");
                                    }
                                  }
                                },
                                child: Text(
                                  '${data.docs[index]['วันสุดท้ายที่ทาน']} ',
                                  style: TextStyle(
                                    fontSize: 12.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('เวลาแจ้งเตือน '),
                              for (int indexItem = 0;
                                  indexItem <
                                      data.docs[index]['เวลาแจ้งเตือน'].length;
                                  indexItem++)
                                InkWell(
                                  onTap: () async {
                                    List<dynamic> dataNoti =
                                        data.docs[index]['เวลาแจ้งเตือน'];
                                    final format = data.docs[index]
                                            ['เวลาแจ้งเตือน'][indexItem]
                                        .split(":");
                                    int hour = int.parse(format[0]);
                                    int minute = int.parse(format[1]);
                                    TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime:
                                          TimeOfDay(hour: hour, minute: minute),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                              alwaysUse24HourFormat: true),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedTime != null) {
                                      // print(data.docs[index]['เวลาแจ้งเตือน']);

                                      dataNoti[indexItem] =
                                          "${pickedTime.hour}:${pickedTime.minute}";

                                      List<dynamic> decodedNoti = jsonDecode(
                                          data.docs[index]['id แจ้งเตือน']);

                                      // Convert the dynamic object to List<List<String>>
                                      List<List<String>> listOfLists =
                                          decodedNoti
                                              .map((e) => List<String>.from(e))
                                              .toList();

                                      await saveDateToFirebase(
                                          data.docs[index]['id'],
                                          data.docs[index]['วันที่เริ่มทาน'],
                                          data.docs[index]['วันสุดท้ายที่ทาน'],
                                          data.docs[index]['สถานะ'],
                                          listOfLists,
                                          data.docs[index]['เวลาแจ้งเตือน']
                                              [indexItem],
                                          data.docs[index]['ชื่อยา'],
                                          data.docs[index]
                                              ['ปริมาณยาที่ทานต่อครั้ง'],
                                          data.docs[index]['หน่วยยา'],
                                          pickedTime,
                                          indexItem);
                                      await noti(
                                          data.docs[index]['id'], dataNoti);
                                    }
                                  },
                                  child: Text(
                                    '${data.docs[index]['เวลาแจ้งเตือน'][indexItem]} ',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          nameUI[index] || amountUI[index]
                              ? IconButton(
                                  icon: const Icon(Icons.check,color: Colors.green,),
                                  onPressed: () {
                                    // อัพเดต 2 ค่าอยู่แล้ว
                                    _saveChanges(index, data.docs[index]);
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // edit รายการ
                                    setState(() {
                                      // แสดงให้แก้ไข 2 รายการ
                                      nameUI[index] = !nameUI[index];
                                      amountUI[index] = !amountUI[index];
                                    });
                                  },
                                ),
                          nameUI[index] || amountUI[index]
                              ? IconButton(
                                  icon: const Icon(Icons.close,color: Colors.red),
                                  onPressed: () {
                                    _cancelChanges(index);
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text(
                                              'คุณต้องการลบยาหรือไม่'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext)
                                                    .pop();
                                              },
                                              child: const Text('ยกเลิก'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                data.docs[index].reference
                                                    .delete();
                                                Navigator.of(dialogContext)
                                                    .pop();
                                              },
                                              child: const Text('ตกลง'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void showDetailDialog(BuildContext context, DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('รายละเอียดยา: ยา${document['ชื่อยา']}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'ปริมาณยาที่ทานต่อครั้ง: ${document['ปริมาณยาที่ทานต่อครั้ง']} ${document['หน่วยยา']}'),
              Text('เวลาทานยา: ${document['เวลาแจ้งเตือน']}'),
              Text('วันที่เริ่มทาน: ${document['วันที่เริ่มทาน']}'),
              Text('วันสุดท้ายที่ทาน: ${document['วันสุดท้ายที่ทาน']}'),
              // เพิ่มรายละเอียดเพิ่มเติมได้ตามต้องการ
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void editData(BuildContext context, DocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicineScreen(document: document),
      ),
    );
  }

  Future<void> deleteData(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('medicine')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting document: $e');
      // Handle errors as needed
    }
  }
}
