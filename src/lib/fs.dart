import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
}

Future<File> get _shopListFile async {
    final path = await _localPath;
    return File('$path/shoplist_v2.json');
}

Future<File> writeShopListString(String stringToWrite) async {
    final file = await _shopListFile;
    return file.writeAsString(stringToWrite);
}

Future<String> loadShopListString() async {
    final file = await _shopListFile;
    String stringFromFile = await file.readAsString();
    return stringFromFile;
}
