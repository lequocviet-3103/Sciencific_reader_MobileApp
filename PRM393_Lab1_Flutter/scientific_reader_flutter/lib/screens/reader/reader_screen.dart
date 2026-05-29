import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ReaderScreen extends StatelessWidget {

  final String markdownText;

  const ReaderScreen({
    super.key,
    required this.markdownText,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Paper Reader",
        ),
      ),

      body: Markdown(
        data: markdownText,
      ),
    );
  }
}