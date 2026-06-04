import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_service.dart';

class UploadResult {
  final String? markdownContent;
  final String? markdownFile;

  const UploadResult({this.markdownContent, this.markdownFile});
}

class UploadService {
  final Dio dio = ApiService().dio;

  Future<UploadResult> uploadPdf({
    File? file,
    Uint8List? bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    if (file == null && bytes == null) {
      throw Exception("No PDF selected.");
    }

    MultipartFile pdfPart;

    if (file != null) {
      pdfPart = await MultipartFile.fromFile(file.path, filename: fileName);
    } else {
      pdfPart = MultipartFile.fromBytes(bytes!, filename: fileName);
    }

    final formData = FormData.fromMap({
      "file": pdfPart,
    });

    final response = await dio.post(
      "/process-paper",
      data: formData,
      onSendProgress: (sent, total) {
        if (total <= 0) return;
        onProgress?.call(sent / total);
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return UploadResult(
        markdownContent: data["markdown_content"] as String?,
        markdownFile: data["markdown_file"] as String?,
      );
    }

    return const UploadResult();
  }
}
