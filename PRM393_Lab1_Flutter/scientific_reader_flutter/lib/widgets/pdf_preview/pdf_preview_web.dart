import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class PdfPreview extends StatefulWidget {
  final Object? file;
  final Uint8List? bytes;

  const PdfPreview({super.key, this.file, this.bytes});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  String? viewType;
  String? objectUrl;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant PdfPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bytes != widget.bytes) {
      _revokeUrl();
      _registerView();
    }
  }

  void _registerView() {
    if (widget.bytes == null) {
      return;
    }

    final blob = html.Blob([widget.bytes!], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final type = 'pdf-preview-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(type, (int viewId) {
      final element = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return element;
    });

    setState(() {
      viewType = type;
      objectUrl = url;
    });
  }

  void _revokeUrl() {
    if (objectUrl != null) {
      html.Url.revokeObjectUrl(objectUrl!);
    }
    objectUrl = null;
  }

  @override
  void dispose() {
    _revokeUrl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bytes == null) {
      return const Center(child: Text("Choose a PDF to preview"));
    }

    if (viewType == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return HtmlElementView(viewType: viewType!);
  }
}
