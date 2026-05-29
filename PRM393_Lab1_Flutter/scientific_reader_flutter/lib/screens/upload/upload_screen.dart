import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../models/recent_paper.dart';
import '../../services/recent_papers_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/pdf_preview/pdf_preview.dart';

class UploadScreen extends StatefulWidget {

  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState()
      => _UploadScreenState();
}

class _UploadScreenState
    extends State<UploadScreen> {
  bool converting = false;
  double? uploadProgress;

  File? selectedFile;
  Uint8List? selectedBytes;
  String? selectedName;
  UploadResult? uploadResult;
  String? errorMessage;
  final RecentPapersService recentPapersService = RecentPapersService();

  Future<void> pickPdf() async {
    setState(() {
      errorMessage = null;
      uploadResult = null;
    });

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
      withReadStream: kIsWeb,
    );

    if (picked == null) return;

    final fileInfo = picked.files.single;

    setState(() {
      selectedName = fileInfo.name;
    });

    if (kIsWeb) {
      Uint8List? bytes = fileInfo.bytes;

      if (bytes == null && fileInfo.readStream != null) {
        final collected = <int>[];
        await for (final chunk in fileInfo.readStream!) {
          collected.addAll(chunk);
        }
        bytes = Uint8List.fromList(collected);
      }

      setState(() {
        selectedBytes = bytes;
        selectedFile = null;
      });
      return;
    }

    if (fileInfo.path == null) {
      setState(() {
        errorMessage = "No file path available.";
      });
      return;
    }

    setState(() {
      selectedFile = File(fileInfo.path!);
      selectedBytes = null;
    });
  }

  Future<void> convertPdf() async {
    if (selectedFile == null && selectedBytes == null) {
      setState(() {
        errorMessage = "Please choose a PDF first.";
      });
      return;
    }

    setState(() {
      converting = true;
      uploadProgress = 0;
      errorMessage = null;
      uploadResult = null;
    });

    try {
      final uploadService = UploadService();

      final result = await uploadService.uploadPdf(
        file: selectedFile,
        bytes: selectedBytes,
        fileName: selectedName ?? "paper.pdf",
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            uploadProgress = progress;
          });
        },
      );

      setState(() {
        uploadResult = result;
      });

      if (result.markdownFile != null &&
          result.markdownFile!.isNotEmpty) {
        await _saveRecentPaper(result.markdownFile!);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }

    setState(() {
      converting = false;
      uploadProgress = null;
    });
  }

  Future<void> _saveRecentPaper(String savedPath) async {
    final name = selectedName ?? savedPath.split("\\").last;
    final item = RecentPaper(
      fileName: name,
      savedPath: savedPath,
      createdAt: DateTime.now().toIso8601String(),
    );

    final items = await recentPapersService.load();
    final updated = [item, ...items]
        .take(20)
        .toList();
    await recentPapersService.save(updated);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Upload PDF"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickPdf,
                    child: const Text("Choose PDF"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: converting ? null : convertPdf,
                    child: const Text("Convert to Markdown"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedName == null
                    ? "No file selected"
                    : "Selected: $selectedName",
                style: const TextStyle(fontSize: 12),
              ),
            ),

            const SizedBox(height: 12),

            if (converting)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: uploadProgress,
                    ),
                    const SizedBox(height: 8),
                    const Text("Converting..."),
                  ],
                ),
              ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildPdfPreview(),
              ),
            ),

            const SizedBox(height: 12),

            _buildResultPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreview() {
    if (kIsWeb) {
      return PdfPreview(bytes: selectedBytes);
    }

    return PdfPreview(
      file: selectedFile,
      bytes: selectedBytes,
    );
  }

  Widget _buildResultPanel() {
    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (uploadResult == null) {
      return const SizedBox.shrink();
    }

    if (uploadResult!.markdown != null &&
        uploadResult!.markdown!.isNotEmpty) {
      return SizedBox(
        height: 180,
        child: Markdown(
          data: uploadResult!.markdown!,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        uploadResult!.markdownFile == null
            ? "Conversion complete."
            : "Saved to: ${uploadResult!.markdownFile}",
        style: const TextStyle(color: Colors.green),
      ),
    );
  }
}