import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    var url =
        Uri.parse("https://falcon-sweet-physically.ngrok-free.app/upload");
    var request = http.MultipartRequest("POST", url);

    var fileStream =
        http.ByteStream(Stream.castFrom(_selectedFile!.openRead()));
    var totalSize = await _selectedFile!.length();
    var uploadedSize = 0;

    var multipartFile = http.MultipartFile(
      'file',
      fileStream.transform(
        StreamTransformer.fromHandlers(
          handleData: (List<int> chunk, EventSink<List<int>> sink) {
            uploadedSize += chunk.length;
            double progress = uploadedSize / totalSize;
            setState(() {
              _uploadProgress = progress;
            });
            sink.add(chunk); // Pass data forward
          },
        ),
      ),
      totalSize,
      filename: _selectedFile!.path.split('/').last,
    );

    request.files.add(multipartFile);

    var response = await request.send();

    response.stream.transform(utf8.decoder).listen((value) {
      print("Response from server: $value");
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload Successful!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload Failed!")),
      );
    }

    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("File Upload with Progress")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedFile != null ? Image.file(_selectedFile!) : Container(),
            _selectedFile != null
                ? Text("Selected File: ${_selectedFile!.path}")
                : Container(),
            SizedBox(height: 20),
            _isUploading
                ? Column(
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress,
                        color: Colors.green,
                      ),
                      SizedBox(height: 10),
                      Text("${(_uploadProgress * 100).toStringAsFixed(2)}%"),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _pickFile,
                    child: Text("Pick File"),
                  ),
            SizedBox(height: 20),
            _selectedFile != null && !_isUploading
                ? ElevatedButton(
                    onPressed: _uploadFile,
                    child: Text("Upload File"),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}












// var url = Uri.parse("https://falcon-sweet-physically.ngrok-free.app/upload");