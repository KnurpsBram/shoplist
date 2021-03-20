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

    /* String reducedProductName; */

    ShopListEntry({@required this.productName, this.inShopList=true, this.checkedOff=false}); //: reducedProductName = reduceProductName(productName);

    String getReducedProductName() => reduceProductName(productName);

    ShopListEntry.fromJson(Map<String, dynamic> json):
        productName        = json['productName'],
        inShopList         = json['inShopList'],
        checkedOff         = json['checkedOff']
    ;

    Map<String, dynamic> toJson() => {
        'productName' : productName,
        'inShopList'  : inShopList,
        'checkedOff'  : checkedOff,
    };

}
