import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/entry.dart';

class HeaderInputField extends Entry {

    HeaderInputField();

    String id = Uuid().v1();

    factory HeaderInputField.fromJson(Map<String, dynamic> attributes) {
        return HeaderInputField();
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': "HeaderInputField",
            "attributes": {}
        };
    }
}
