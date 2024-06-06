import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Addprofile extends StatefulWidget {
  const Addprofile({super.key});

  @override
  State<Addprofile> createState() => _AddprofileState();
}

class _AddprofileState extends State<Addprofile> {
  final nameController = TextEditingController();

  Future<void> fetchData() async {
    CollectionReference names = FirebaseFirestore.instance.collection('name');

    try {
      DocumentSnapshot snapshot = await names.doc("hzjqFYmp7ywHhSLMDlxN").get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        nameController.text =
            data['name']; // Set the fetched name to the controller
      } else {
        nameController.text = "กรุณาเพิ่มชื่อ-นามสกุล";
      }
    } catch (e) {
      nameController.text = "Error fetching data: $e";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(88, 135, 255, 1),
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
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        margin: const EdgeInsets.only(top: 30.0),
        child: ListView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/profile.png",
                        width: 100,
                        height: 100,
                      ),
                      const Text(
                        "ชื่อ - สกุล",
                        style: TextStyle(
                            fontFamily: 'SukhumvitSet-Bold', fontSize: 23),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            flex: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 20, left: 10, right: 10),
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0),
                                  width: double.maxFinite,
                                  child: TextFormField(
                                    style: const TextStyle(
                                        fontSize: 25.0,
                                        fontFamily: 'SukhumvitSet-Bold',
                                        color: Colors.white),
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 15),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none)),
                                      filled: true,
                                      hintStyle: TextStyle(
                                          fontFamily: 'SukhumvitSet-Medium',
                                          color: Colors.white),
                                      fillColor:
                                          Color.fromRGBO(84, 164, 244, 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
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
                        (states) => Colors.blue),
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
                        (states) => Colors.blue),
                    elevation: MaterialStateProperty.resolveWith<double>(
                      (Set<MaterialState> states) {
                        return 2.0;
                      },
                    ),
                  ),
                  onPressed: () {
                    CollectionReference names =
                        FirebaseFirestore.instance.collection('name');
                    names.doc("hzjqFYmp7ywHhSLMDlxN").update({
                      'name': nameController.text,
                    }).then((_) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.of(context).pop(true);
                          });
                          return AlertDialog(
                            title: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(
                                    width:
                                        10), // เพิ่มช่องว่างระหว่างไอคอนและข้อความ
                                Text('การแจ้งเตือน'),
                              ],
                            ),
                            content: Text('อัปเดตชื่อสำเร็จ'),
                          );
                        },
                      );

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('อัปเดตชื่อสำเร็จ')),
                      // );
                    }).catchError((error) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.of(context).pop(true);
                          });

                          return AlertDialog(
                            title: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red),
                                SizedBox(
                                    width:
                                        10), // เพิ่มช่องว่างระหว่างไอคอนและข้อความ
                                Text('การแจ้งเตือน'),
                              ],
                            ),
                            content: Text('อัปเดตชื่อไม่สำเร็จ: $error'),
                          );
                        },
                      );
                      
                    });
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
