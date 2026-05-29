import 'package:flutter/material.dart';

import '../../models/recent_paper.dart';
import '../../services/recent_papers_service.dart';
import '../upload/upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecentPapersService recentPapersService = RecentPapersService();
  List<RecentPaper> recentPapers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final items = await recentPapersService.load();
    if (!mounted) return;
    setState(() {
      recentPapers = items;
      loading = false;
    });
  }

  Future<void> _openUpload() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UploadScreen(),
      ),
    );

    await _loadRecents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Research Reader",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openUpload,
                child: const Text("Upload PDF"),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Papers",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildRecentList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (recentPapers.isEmpty) {
      return const Center(
        child: Text("No uploads yet."),
      );
    }

    return ListView.separated(
      itemCount: recentPapers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = recentPapers[index];

        return ListTile(
          title: Text(item.fileName),
          subtitle: Text(item.savedPath),
        );
      },
    );
  }
}