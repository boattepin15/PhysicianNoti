import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/menu/menulist.dart';
import 'package:flutter_application_1/screen/editmedicine.dart';

class listmedicine extends StatefulWidget {
  const listmedicine({super.key});

  @override
  State<listmedicine> createState() => _listmedicineState();
}

class _listmedicineState extends State<listmedicine> {
  final Stream<QuerySnapshot> user =
      FirebaseFirestore.instance.collection('medicine').snapshots();
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
                return GestureDetector(
                  onTap: () {
                    showDetailDialog(context, data.docs[index]);
                  },
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(
                        '${data.docs[index]['ชื่อยา']} ${data.docs[index]['ปริมาณยาที่ทานต่อครั้ง']} ${data.docs[index]['หน่วยยา']} ',
                        style: const TextStyle(fontSize: 25),
                      ),
                      subtitle: Text(
                        'เริ่มทาน ${data.docs[index]['วันที่เริ่มทาน']} เวลาแจ้งเตือน ${data.docs[index]['เวลาแจ้งเตือน']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              editData(context, data.docs[index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('คุณต้องการลบยาหรือไม่'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('ยกเลิก'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          data.docs[index].reference.delete();
                                          Navigator.of(dialogContext)
                                              .pop(); // Close the dialog
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
              Text('ความถี่: ${document['ความถี่']}'),
              Text('เริ่มทานเมื่อ: ${document['วันที่เริ่มทาน']}'),
              Text('เวลาทานยา: ${document['เวลาแจ้งเตือน']}'),
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
