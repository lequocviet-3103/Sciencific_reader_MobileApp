import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreview extends StatelessWidget {
  final Object? file;
  final Uint8List? bytes;

  const PdfPreview({super.key, this.file, this.bytes});

  @override
  Widget build(BuildContext context) {
    final resolvedFile = file as File?;

    if (resolvedFile == null && bytes == null) {
      return const Center(child: Text("Choose a PDF to preview"));
    }

    if (bytes != null) {
      return SfPdfViewer.memory(bytes!);
    }

    return SfPdfViewer.file(resolvedFile!);
  }
}
