import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/entry.dart';

class ProductInputField extends Entry {

    ProductInputField();

    String text = "";
    String id = Uuid().v1();

    factory ProductInputField.fromJson(Map<String, dynamic> attributes) {
        return ProductInputField();
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': "ProductInputField",
            "attributes": {}
        };
    }
}
