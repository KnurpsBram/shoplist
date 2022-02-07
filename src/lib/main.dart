import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/screens/home.dart';
import 'package:shoplist/models/appdata.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  AppData appData = AppData();

  runApp(MainApp(appData));

}

class MainApp extends StatelessWidget {

    AppData appData;

    MainApp(this.appData);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'ShopList',
            home: HomeScreen(appData)
        );
    }
}
