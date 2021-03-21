import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'util.dart';

class ShopListEntry{
    String productName;
    bool inShopList;
    bool checkedOff;
    int  homeIndex;
    int  supermarketIndex;

    ShopListEntry({@required this.productName, this.inShopList=true, this.checkedOff=false, this.homeIndex=-1, this.supermarketIndex=-1});

    String getReducedProductName() => reduceProductName(productName);

    ShopListEntry.fromJson(Map<String, dynamic> json):
        productName      = json['productName'],
        inShopList       = json['inShopList'],
        checkedOff       = json['checkedOff'],
        homeIndex        = json['homeIndex'],
        supermarketIndex = json['supermarketIndex']
    ;

    Map<String, dynamic> toJson() => {
        'productName'      : productName,
        'inShopList'       : inShopList,
        'checkedOff'       : checkedOff,
        'homeIndex'        : homeIndex,
        'supermarketIndex' : supermarketIndex,
    };

}
