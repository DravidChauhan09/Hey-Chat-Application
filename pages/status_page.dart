import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadStatusPage extends StatefulWidget {
  const UploadStatusPage({super.key});

  @override
  _UploadStatusPageState createState() => _UploadStatusPageState();
}

class _UploadStatusPageState extends State<UploadStatusPage> {
  File? _statusFile;
  bool _isVideo = false;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _statusFile = File(pickedFile.path);
        _isVideo = pickedFile.path.endsWith('.mp4');
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _statusFile = File(pickedFile.path);
        _isVideo = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Status')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Allow user to pick either an image or video
                await _pickFile();
                if (_statusFile == null) {
                  await _pickVideo();
                }
              },
              child: const Text('Pick Status'),
            ),
            const SizedBox(height: 16),
            if (_statusFile != null)
              _isVideo
                  ? Container(
                width: double.infinity,
                height: 200,
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              )
                  : Image.file(
                _statusFile!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
