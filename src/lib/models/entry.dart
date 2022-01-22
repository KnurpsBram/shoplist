// import 'dart:async';
// import 'dart:io';
// import 'dart:convert';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
//
// import 'package:shoplist/util/misc.dart';
// import 'package:shoplist/models/appdata.dart';
//
// class Entry {
//
//     String text;
//     String id = Uuid().v1();
//
//     Entry({this.text=""});
//
//     factory Entry.fromJson(Map<String, dynamic> json) {
//         switch (json['classType']) {
//             case "RouteEntry":
//                 return RouteEntry.fromJson(json["attributes"]);
//             case "ProductEntry":
//                 return ProductEntry.fromJson(json["attributes"]);
//             case "HeaderEntry":
//                 return HeaderEntry.fromJson(json["attributes"]);
//             case "ProductInputField":
//                 return ProductInputField.fromJson(json["attributes"]);
//             case "HeaderInputField":
//                 return HeaderInputField.fromJson(json["attributes"]);
//         }
//     }
// }
