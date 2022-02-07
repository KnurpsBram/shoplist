import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/entry.dart';
import 'package:shoplist/util/misc.dart';

class ProductEntry extends Entry {

    String text;
    bool isCheckedOff;

    ProductEntry({@required this.text, this.isCheckedOff=false});

    String id = Uuid().v1();
    String reducedProductName() => reduceProductName(text);

    factory ProductEntry.fromJson(Map<String, dynamic> attributes) {
        return ProductEntry(
            text: attributes['text'],
            isCheckedOff: attributes["isCheckedOff"]
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': 'ProductEntry',
            'attributes': {
                'text': text,
                'isCheckedOff': isCheckedOff
            }
        };
    }
}
