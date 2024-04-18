import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditMedicineScreen extends StatefulWidget {
  final DocumentSnapshot document;

  const EditMedicineScreen({Key? key, required this.document})
      : super(key: key);

  @override
  _EditMedicineScreenState createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  late TextEditingController _medicineNameController;
  late TextEditingController _doseController;
  late TextEditingController _unitController;
  late TextEditingController _frequencyController;
  late TextEditingController _startDateController;
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    _medicineNameController =
        TextEditingController(text: widget.document['ชื่อยา']);
    _doseController =
        TextEditingController(text: widget.document['ปริมาณยาที่ทานต่อครั้ง']);
    _unitController = TextEditingController(text: widget.document['หน่วยยา']);
    _frequencyController =
        TextEditingController(text: widget.document['ความถี่']);
    _startDateController =
        TextEditingController(text: widget.document['วันที่เริ่มทาน']);
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _doseController.dispose();
    _unitController.dispose();
    _frequencyController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลยา: ${widget.document['ชื่อยา']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: _medicineNameController,
                decoration: const InputDecoration(
                    labelText: 'ชื่อยา', labelStyle: TextStyle(fontSize: 23)),
                style: const TextStyle(fontSize: 25)),
            TextField(
                controller: _doseController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'ปริมาณยาที่ทานต่อครั้ง',
                  labelStyle: TextStyle(fontSize: 23),
                ),
                style: const TextStyle(fontSize: 25)),
            TextButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(), // ตั้งค่าวันที่เริ่มต้น
                  firstDate: DateTime(2015, 8), // วันที่แรกที่สามารถเลือกได้
                  lastDate: DateTime(2101), // วันสุดท้ายที่สามารถเลือกได้
                  initialDatePickerMode:
                      DatePickerMode.day, // เซ็ตโหมดเป็นเลือกวันที่เท่านั้น
                );
                if (picked != null && picked != _startDate) {
                  setState(() {
                    _startDate = picked;
                    _startDateController.text = DateFormat('yyyy-MM-dd').format(
                        picked); // กำหนดค่าให้กับ TextField โดยการใช้ DateFormat
                  });
                }
              },
              child: const Text(
                'เลือกวันที่เริ่มทาน',
                style: TextStyle(fontSize: 20),
              ),
            ),
            TextField(
              controller: _startDateController,
              enabled:
                  false, // ปิดการใช้งาน TextField เพื่อให้มองเป็น Label เท่านั้น
              decoration: const InputDecoration(labelText: 'วันที่เริ่มทาน'),
              style: const TextStyle(fontSize: 22, color: Colors.black),
            ),
            TextField(
              controller: _startDateController,
              enabled:
                  false, // ปิดการใช้งาน TextField เพื่อให้มองเป็น Label เท่านั้น
              decoration: const InputDecoration(labelText: 'วันที่สิ้นสุดการทาน'),
              style: const TextStyle(fontSize: 22, color: Colors.black),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_doseController.text.isNotEmpty &&
                    double.parse(_doseController.text) <= 1000.99) {
                  try {
                    await widget.document.reference.update({
                      'ชื่อยา': _medicineNameController.text,
                      'ปริมาณยาที่ทานต่อครั้ง': _doseController.text,
                      'หน่วยยา': _unitController.text,
                      'ความถี่': _frequencyController.text,
                      'วันที่เริ่มทาน': _startDateController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('บันทึกการแก้ไขเรียบร้อยแล้ว')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error updating document: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('เกิดข้อผิดพลาดในการบันทึกการแก้ไข')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('กรุณากรอกปริมาณยาที่ไม่เกิน 1000')),
                  );
                }
              },
              child: const Text(
                'บันทึกการแก้ไข',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
