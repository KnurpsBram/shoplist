import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class ShopListEntry{
    final String productName;
    bool checkedOff;

    ShopListEntry({ @required this.productName, this.checkedOff=false});

    ShopListEntry.fromJson(Map<String, dynamic> json):
        productName = json['productName'],
        checkedOff  = json['checkedOff']
    ;

    Map<String, dynamic> toJson() => {
        'productName' : productName,
        'checkedOff'  : checkedOff
    };
}
