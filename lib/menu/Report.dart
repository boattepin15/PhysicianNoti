import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/menu/menulist.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final Stream<QuerySnapshot> user =
      FirebaseFirestore.instance.collection('medicine').snapshots();
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
                  margin: const EdgeInsets.fromLTRB(20, 20, 0, 10), // กำหนด margin สำหรับ Row
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('ข้อมูลยา', style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold)),
                      SizedBox(width:140), // เพิ่มระยะห่างระหว่าง Text สถานะยา และ Text ข้อมูลยา
                      Text('สถานะยา', style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          '${data.docs[index]['ชื่อยา']} ${data.docs[index]['ปริมาณยาที่ทานต่อครั้ง']} ${data.docs[index]['หน่วยยา']} ',
                          style: const TextStyle(fontSize: 23),
                        ),
                      );
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
