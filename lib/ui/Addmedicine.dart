import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/ui/freq.dart';

class Addmedicine extends StatefulWidget {
  const Addmedicine({super.key});

  @override
  State<Addmedicine> createState() => _Addmedicine();
}

class _Addmedicine extends State<Addmedicine> {
  TextEditingController MedicineQuantity = TextEditingController();
  TextEditingController NameMedicineController = TextEditingController();
  String selectedDropdownValue = "";

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "กรุณาเพิ่มยา",
          style: TextStyle(fontSize: 25, fontFamily: 'SukhumvitSet-Bold'),
        ),
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
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        margin: const EdgeInsets.only(top: 30.0),
        child: ListView(children: [
          Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /////////////////////ชื่อยา/////////////////////////////////////////////////////
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, left: 10, right: 10),
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15.0),
                                    width: double.maxFinite,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ชื่อยา', // Your additional text here
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontFamily: 'SukhumvitSet-Bold',
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                10), // Adjust the spacing between text and TextField
                                        TextField(
                                          controller: NameMedicineController,
                                          enabled: true,
                                          style: const TextStyle(
                                            fontSize: 25.0,
                                            fontFamily: 'SukhumvitSet-Bold',
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 15,
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20.0),
                                              ),
                                              borderSide: BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            filled: true,
                                            hintText: "ชื่อยา",
                                            hintStyle: TextStyle(
                                              fontFamily: 'SukhumvitSet-Medium',
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          inputFormatters: [
                                            // กำหนดให้ไม่เกิน 15 ตัวอักษร
                                            LengthLimitingTextInputFormatter(
                                                15),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ///////////////////////////ปริมาณยาที่ทานต่อครั้ง//////////////////////////////
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, left: 10, right: 10),
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15.0),
                                    width: double.maxFinite,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ปริมาณยาที่ทานต่อครั้ง', // Your additional text here
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontFamily: 'SukhumvitSet-Bold',
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                10), // Adjust the spacing between text and TextField
                                        TextField(
                                          controller: MedicineQuantity,
                                          enabled: true,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                10),
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}'))
                                          ],
                                          onChanged: (value) {
                                            // Parse the value and ensure it doesn't exceed 1100
                                            double enteredValue =
                                                double.tryParse(value) ?? 0.0;
                                            if (enteredValue > 1001) {
                                              // Update the value to be 1100
                                              MedicineQuantity.text = '1';
                                            }
                                          },
                                          style: const TextStyle(
                                            fontSize: 25.0,
                                            fontFamily: 'SukhumvitSet-Bold',
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 15,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none),
                                            ),
                                            filled: true,
                                            hintText: "1",
                                            hintStyle: TextStyle(
                                              fontFamily: 'SukhumvitSet-Medium',
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
/////////////////////////////หน่วย/////////////////////////////////////////////////
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, left: 10, right: 10),
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15.0),
                                    width: double.maxFinite,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'หน่วยยา', // Your additional text here
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontFamily: 'SukhumvitSet-Bold',
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        DropdownButtonFormField<String>(
                                          items: const [
                                            DropdownMenuItem(
                                              value: "เม็ด",
                                              child: Text(
                                                "เม็ด",
                                                style: TextStyle(
                                                  fontFamily:
                                                      'SukhumvitSet-Medium',
                                                  fontSize: 22.0,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: "ช้อนชา",
                                              child: Text("ช้อนชา",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'SukhumvitSet-Medium',
                                                    fontSize: 22.0,
                                                  )),
                                            ),
                                            DropdownMenuItem(
                                              value: "ช้อนโต๊ะ",
                                              child: Text("ช้อนโต๊ะ",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'SukhumvitSet-Medium',
                                                    fontSize: 22.0,
                                                  )),
                                            ),
                                          ],
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedDropdownValue = value ??
                                                  "1"; // Update the selected value
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
                                        )
                                      ],
                                    ),
                                  ),
                                  // Container(
                                  //     padding: EdgeInsets.only(top: 20),
                                  //     alignment: Alignment.center,
                                  //     child: _buildChipsTypeTime())
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ]),
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
                    Navigator.pop(context);
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
                  onPressed: () {
                    String nameMedicine = NameMedicineController.text;
                    String medicineQuantity = MedicineQuantity.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => frequency(
                                // 23/5/2567 แก้ไขทำให้ชื่อและจำนวนยาห้ามว่าง
                                nameMedicine: nameMedicine.length == 0
                                    ? "None"
                                    : nameMedicine,
                                medicineQuantity: medicineQuantity.length == 0
                                    ? "1"
                                    : medicineQuantity,
                                selectedDropdownValue: selectedDropdownValue,
                              )),
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
