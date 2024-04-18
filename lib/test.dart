import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class test extends StatefulWidget {
  const test({super.key});

  @override
  State<test> createState() => _testState();
}
bool _isMedicationPressed = false;
class _testState extends State<test> {
  final nameController = TextEditingController();
  final listmedicineController = TextEditingController();
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
bool _isPressed = false;

  @override
   Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Card Example'),
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            // Handle the tap event here
          },
          child: Card(
            color: _isPressed ? Colors.green : const Color.fromARGB(255, 251, 4, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Color.fromARGB(255, 225, 225, 225),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isPressed = !_isPressed;
                  });
                },
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Card Text",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _handleConfirmation();
                            },
                            child: Text('Confirm'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _handleCancellation();
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    ),
  );
}

void _handleConfirmation() {
  setState(() {
    _isPressed = true;
  });
}

void _handleCancellation() {
  setState(() {
    _isPressed = false;
  });
}
}


  
  

