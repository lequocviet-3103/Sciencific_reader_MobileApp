import 'dart:io';

class VaultService {

  Future<void> saveMarkdown(
    String vaultPath,
    String fileName,
    String markdown,
  ) async {

    final papersFolder =
        Directory("$vaultPath/Papers");

    if (!papersFolder.existsSync()) {
      papersFolder.createSync(
        recursive: true,
      );
    }

    final file = File(
      "$vaultPath/Papers/$fileName",
    );

    await file.writeAsString(markdown);
  }
}