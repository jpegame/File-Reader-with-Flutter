import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'pdf_view_page.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  Uint8List? fileBytes;
  PlatformFile? file;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );

    if (result == null) return;

    if (kIsWeb) {
      setState(() {
        fileBytes = result.files.single.bytes;
        file = result.files.single;
      });
    } else {
      final selectedFile = File(result.files.single.path!);
      final bytes = await selectedFile.readAsBytes();
      setState(() {
        fileBytes = bytes;
        file = result.files.single;
      });
    }

    // Navigate only if the widget is still mounted
    if (!mounted) return;

    if (fileBytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PdfPage(pdfBytes: fileBytes!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: pickFile, child: const Text("Select PDF")),
          const SizedBox(height: 20),
          Text(file != null ? "Selected: ${file?.name}" : "No file selected"),
        ],
      ),
    );
  }
}
