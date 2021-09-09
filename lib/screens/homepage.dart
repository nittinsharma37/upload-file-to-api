import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  @override
  Widget build(BuildContext context) {
    final fileName = imageFile != null ? imageFile!.path : "No file Selected";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image to server"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text("Select image"),
              onPressed: () {
                selectFile();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Center(child: Text(fileName)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text("upload image"),
              onPressed: () {
                uploadFile(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ["jpg", "jpeg", "png"]);

    if (result == null) {
      return;
    }

    final path = result.files.single.path;
    setState(() {
      imageFile = File(path);
    });
  }

  uploadFile(context) async {
    if (imageFile == null) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a file !"),
      ));
    } else {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("https://codelime.in/api/remind-app-token"),
        );
        Map<String, String> headers = {"Content-type": "multipart/form-data"};

        request.files.add(
          http.MultipartFile(
            'image',
            imageFile!.readAsBytes().asStream(),
            imageFile!.lengthSync(),
            filename: "filename",
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        request.headers.addAll(headers);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("request: " + request.toString()),
        ));
        // print("request: " + request.toString());
        request.send().then((value) {
          return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: value.statusCode == 200
                ? Text("File uploaded successfully with status code : " +
                    value.statusCode.toString())
                : const Text("Image not uploaded"),
          ));
        });
      } catch (err) {
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong !"),
        ));
      }
    }
  }
}
