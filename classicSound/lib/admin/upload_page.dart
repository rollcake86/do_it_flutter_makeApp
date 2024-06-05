import 'package:classicsound/data/music.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['piano', 'voice', 'violin'];

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UploadPageState();
  }
}

class _UploadPageState extends State<UploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FilePickerResult 인스턴스 생성
  FilePickerResult? _pickedFile;
  FilePickerResult? _imagePickedFile;

  // 로컬에 있는 파일의 경로와 이름
  String? _filePath;
  String? _imageFilePath;

  // 로컬에 있는 파일의 이름
  String? _fileName;
  String? _imageFileName;

  // 업로드된 파일의 다운로드 URL
  String? _downloadUrl;

  // 업로드 중인지 여부
  bool _isUploading = false;

  final TextEditingController _composerController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  String dropdownValue = list.first;

  // 로컬에서 파일을 선택하는 메서드
  Future<void> _pickFile(int type) async {
    var picked = await FilePicker.platform.pickFiles();
    // // 선택된 파일이 있다면
    if (picked != null) {
      // 파일의 경로와 이름을 저장
      if (type == 1) {
        setState(() {
          _pickedFile = picked;
          _filePath = _pickedFile!.files.first.name;
          _fileName = _pickedFile!.files.first.name;
        });
      } else {
        setState(() {
          _imagePickedFile = picked;
          _imageFilePath = _imagePickedFile!.files.first.name;
          _imageFileName = _imagePickedFile!.files.first.name;
        });
      }
    }
  }

  // Firebase Storage에 파일을 업로드하는 메서드
  Future<void> _uploadFile() async {
    // 파일이 선택되었다면
    if (_filePath != null) {
      // 참조 생성
      Reference reference = _storage.ref().child('files/$_fileName');

      // 파일 업로드 (파일의 바이트를 사용)
      TaskSnapshot uploadTask =
          await reference.putData(_pickedFile!.files.first.bytes!);

      setState(() {
        _isUploading = true;
      });

      // 다운로드 URL 얻기
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      CollectionReference _filesRef = _firestore.collection('files');
      String imageDownloadUrl = '';
      if(_imageFilePath != null) {
        Reference reference = _storage.ref().child('files/$_imageFileName');

        // 파일 업로드 (파일의 바이트를 사용)
        TaskSnapshot uploadTask =
        await reference.putData(_imagePickedFile!.files.first.bytes!);

        // 다운로드 URL 얻기
        imageDownloadUrl = await uploadTask.ref.getDownloadURL();
      }

      // URL 저장
      Music music = Music(
          _fileName!,
          _composerController.value.text,
          _tagController.value.text,
          dropdownValue,
          _pickedFile!.files.single.size,
          'audio/${_pickedFile!.files.single.extension}',
          downloadUrl , imageDownloadUrl);

      await _filesRef.add(music.toMap());

      setState(() {
        _downloadUrl = downloadUrl;
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                decoration: InputDecoration(hintText: '작곡가'),
                controller: _composerController,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(hintText: 'TAG (콤마로 구분)'),
                controller: _tagController,
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.music_note),
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _pickFile(1);
              },
              child: Text('Pick a file $_fileName'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _pickFile(2);
              },
              child: Text('이미지 파일 $_imageFileName'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload to Firebase Storage'),
            ),
            SizedBox(height: 16),
            _downloadUrl != null
                ? Text('File uploaded successfully')
                : Text('No file to display'),
            SizedBox(height: 16),
            _isUploading
                ? const CircularProgressIndicator(
                    strokeWidth: 10,
                  )
                : Text('No file uploading'),
          ],
        ),
      ),
    );
  }
}
