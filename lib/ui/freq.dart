import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/Addmedicine.dart';
import 'package:flutter_application_1/ui/Addtime.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';

StreamController<List<String>> selectedDaysController =
    StreamController<List<String>>.broadcast();

class frequency extends StatefulWidget {
  final String nameMedicine;
  final String medicineQuantity;
  final String selectedDropdownValue;
  const frequency(
      {super.key,
      required this.nameMedicine,
      required this.medicineQuantity,
      required this.selectedDropdownValue});

  @override
  State<frequency> createState() => _frequencyState();
}


class _frequencyState extends State<frequency> {
  TextEditingController txtHBDController = TextEditingController();
  TextEditingController NameMedicineController = TextEditingController();
  TextEditingController MedicineQuantity = TextEditingController();

  void datestart(BuildContext context) {
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
        // era: EraMode.BUDDHIST_YEAR,
        context: context,
        height: 330,
        fontFamily: 'SukhumvitSet-Bold',
        // locale: const Locale("th"),
        initialDate: DateTime.now(),
        firstDate: DateTime(1850),
        lastDate: DateTime(yearCurrent),
      ).then((date) {
        setState(() {
          var strDay = DateFormat('dd/MM/yyyy').format(date!);
          txtHBDController.text = strDay;
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
        title: const Text(
          "วันที่เริ่มทานยา",
          style: TextStyle(fontSize: 25, fontFamily: 'SukhumvitSet-Bold'),
        ),
        leading: IconButton(
          icon: const ImageIcon(
            AssetImage("assets/images/arrow_left.png"),
            size: 40,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: 20, left: 10, right: 10),
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the start
                          children: [
                            const Text(
                              "เริ่มต้น",
                              style: TextStyle(
                                fontSize: 23.0,
                                fontFamily: 'SukhumvitSet-Medium',
                                color: Colors.black,
                              ),
                            ),
                            // Text('ชื่อยา: ${widget.nameMedicine}'),
                            // Text('ปริมาณยา: ${widget.medicineQuantity}'),
                            // Text('หน่วย: ${widget.selectedDropdownValue}'),
                            const SizedBox(
                                height:
                                    10), // Adjust the spacing between "เริ่มต้น" and TextField
                            TextField(
                              onTap: () {
                                datestart(context);
                              },
                              controller: txtHBDController,
                              readOnly: true,
                              style: const TextStyle(
                                fontSize: 25.0,
                                fontFamily: 'SukhumvitSet-Bold',
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 15,
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  borderSide: BorderSide(
                                      width: 0, style: BorderStyle.none),
                                ),
                                filled: true,
                                hintText: "วันที่เริ่มทาน",
                                hintStyle: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'SukhumvitSet-Medium',
                                  color: Colors.grey[800],
                                ),
                                fillColor:
                                    const Color.fromRGBO(211, 234, 250, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text(
                          "ย้อนกลับ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontFamily: 'SukhumvitSet-Bold'),
                        ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Addtime(
                          nameMedicine: widget.nameMedicine,
                          medicineQuantity: widget.medicineQuantity,
                          selectedDropdownValue: widget.selectedDropdownValue,
                          startDate: txtHBDController.text,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ถัดไป",
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
