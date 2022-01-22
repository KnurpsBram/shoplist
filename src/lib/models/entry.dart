import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/route-entry.dart';
import 'package:shoplist/models/product-entry.dart';
import 'package:shoplist/models/header-entry.dart';
import 'package:shoplist/models/product-input-field.dart';
import 'package:shoplist/models/header-input-field.dart';

class Entry {

    Entry();

    factory Entry.fromJson(Map<String, dynamic> json) {
        switch (json['classType']) {
            case "RouteEntry":
                return RouteEntry.fromJson(json["attributes"]);
            case "ProductEntry":
                return ProductEntry.fromJson(json["attributes"]);
            case "HeaderEntry":
                return HeaderEntry.fromJson(json["attributes"]);
            case "ProductInputField":
                return ProductInputField.fromJson(json["attributes"]);
            case "HeaderInputField":
                return HeaderInputField.fromJson(json["attributes"]);
        }
    }
}
