import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _imagePathsKey = 'image_paths';

  Future<String> saveImage(XFile image) async {
    final sourceFile = File(image.path);
    if (!await sourceFile.exists()) {
      throw Exception('Selected image file does not exist');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = p.join(photosDir.path, 'photo_$timestamp.jpg');
    await sourceFile.copy(newPath);
    return newPath;
  }

  Future<void> savePathsList(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_imagePathsKey, paths);
  }

  Future<List<String>> loadPathsList() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_imagePathsKey) ?? [];
    return paths.where((path) => File(path).existsSync()).toList();
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
