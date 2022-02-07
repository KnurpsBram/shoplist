import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/entry.dart';

class RouteEntry extends Entry {

    String text;

    RouteEntry({@required this.text});

    String id = Uuid().v1();

    factory RouteEntry.fromJson(Map<String, dynamic> attributes) {
        return RouteEntry(
            text: attributes['text'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': 'RouteEntry',
            'attributes': {'text': text}
        };
    }
}
