import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/entry.dart';

class HeaderEntry extends Entry {

    String text;

    HeaderEntry({@required this.text});

    String id = Uuid().v1();

    factory HeaderEntry.fromJson(Map<String, dynamic> attributes) {
        return HeaderEntry(text: attributes["text"]);
    }

    Map<String, dynamic> toJson() {
          return {
            'classType': "HeaderEntry",
            'attributes': {'text': text}
        };
    }
}
