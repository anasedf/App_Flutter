import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FodmapsScreen(),
    );
  }
}

class FodmapsScreen extends StatefulWidget {
  @override
  _FodmapsScreenState createState() => _FodmapsScreenState();
}

class _FodmapsScreenState extends State<FodmapsScreen> {
  File? _image;
  String _prediction = "?????";
  String _fodmap = "";

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _prediction = "?????"; // รีเซ็ตค่าเมื่อเปลี่ยนรูป
        _fodmap = "";
      });
    }
  }

  Future<void> _predictImage() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://172.20.10.4:5000/predict'), // 🔥 เปลี่ยนเป็น URL ของ API
    );
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      setState(() {
        _prediction = jsonData['prediction'];
        _fodmap = "FODMAP: ${jsonData['fodmap']}";
      });
    } else {
      setState(() {
        _prediction = "Error!";
        _fodmap = "Failed to predict";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fodmaps")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Fodmaps", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                width: 250,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null
                    ? Center(child: Text("ไม่มีรูปภาพ", style: TextStyle(color: Colors.grey)))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _predictImage,
                    child: Text("Predict"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Upload Image"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(_prediction, style: TextStyle(color: Colors.white, fontSize: 16)),
                    if (_fodmap.isNotEmpty) Text(_fodmap, style: TextStyle(color: Colors.yellow, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
