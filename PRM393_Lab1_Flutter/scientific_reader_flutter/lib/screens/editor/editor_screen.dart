import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';

class EditorScreen extends StatefulWidget {
  final String markdownContent;
  final String markdownFile;

  const EditorScreen({
    super.key,
    required this.markdownContent,
    required this.markdownFile,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController _controller;
  final Dio _dio = ApiService().dio;
  bool _saving = false;

  static const String _obsidianVaultName = 'PRM393_Lab1';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.markdownContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveMarkdown() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await _dio.post(
        '/update-markdown',
        data: {
          'file_path': widget.markdownFile,
          'content': _controller.text,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu thành công')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?['detail']?.toString() ?? e.message ?? 'Lưu thất bại'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _openInObsidian() async {
    final relativePath = _relativeObsidianPath(widget.markdownFile);
    final uri = Uri(
      scheme: 'obsidian',
      host: 'open',
      queryParameters: {
        'vault': _obsidianVaultName,
        'file': relativePath,
      },
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được Obsidian')),
      );
    }
  }

  String _relativeObsidianPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final vaultPrefix = 'vault/';

    if (normalized.startsWith(vaultPrefix)) {
      return normalized.substring(vaultPrefix.length);
    }

    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Editor'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _saveMarkdown,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Lưu'),
          ),
          TextButton.icon(
            onPressed: _openInObsidian,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Obsidian'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.markdownFile,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _controller,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}