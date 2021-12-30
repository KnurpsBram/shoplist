import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'util.dart';

/* class Entry {
  String text;
  Entry({this.text=""})
}

class CheckListProductEntry extends Entry {
  // TODO: inherit from superclass
  // define how a tile looks like in homelist, triplist and in supermarketorder
}

class CheckListProductInputField extends Entry {
  // TODO: inherit from superclass
  // define how a tile looks like in homelist, triplist and in supermarketorder
}

class CheckListHeaderEntry extends Entry {
  // TODO: inherit from superclass
  // define how a tile looks like in homelist, triplist and in supermarketorder
}

class CheckListHeaderInputField extends Entry {
  // TODO: inherit from superclass
  // define how a tile looks like in homelist, triplist and in supermarketorder
}

class SuperMarketOrderEntry extends Entry {

}

class SuperMarketOrderInputField extends Entry {

} */

class ShopListEntry{
    String productName;
    bool inShopList;
    bool checkedOff;
    bool isHeader; // TODO: wouldn't it be better if there is a separate class for listItemHeader and listItemProduct or something?
    bool isHeaderInputField; // TODO: separate classes (subclasses?) for these purposes
    bool isEntryInputField; // TODO: separate classes for these purposes
    int  homeIndex;
    int  supermarketIndex;

    ShopListEntry({@required this.productName, this.inShopList=true, this.checkedOff=false, this.isHeader=false, this.isHeaderInputField=false, this.isEntryInputField=false, this.homeIndex=-1, this.supermarketIndex=-1});

    String getReducedProductName() => reduceProductName(productName);

    ShopListEntry.fromJson(Map<String, dynamic> json):
        productName        = json['productName'],
        inShopList         = json['inShopList'],
        checkedOff         = json['checkedOff'],
        isHeader           = json['isHeader'],
        isHeaderInputField = json['isHeaderInputField'],
        isEntryInputField  = json['isEntryInputField'],
        homeIndex          = json['homeIndex'],
        supermarketIndex   = json['supermarketIndex']
    ;

    Map<String, dynamic> toJson() => {
        'productName'        : productName,
        'inShopList'         : inShopList,
        'checkedOff'         : checkedOff,
        'isHeader'           : isHeader,
        'isHeaderInputField' : isHeaderInputField,
        'isEntryInputField'  : isEntryInputField,
        'homeIndex'          : homeIndex,
        'supermarketIndex'   : supermarketIndex,
    };

    String hintText() {
      if (isHeaderInputField) {
        return "tap to create new header...";
      } else if (isEntryInputField) {
        return "tap to create new entry...";
      } else {
        return "BUG! this text should not be here";
      }
    }
}

class ShopListEntrySubClass extends ShopListEntry {
    String productName;
    bool inShopList;
    bool checkedOff;
    bool isHeader; // TODO: wouldn't it be better if there is a separate class for listItemHeader and listItemProduct or something?
    bool isHeaderInputField; // TODO: separate classes (subclasses?) for these purposes
    bool isEntryInputField; // TODO: separate classes for these purposes
    int  homeIndex;
    int  supermarketIndex;
    bool isSubClass;

    ShopListEntrySubClass({@required this.productName, this.inShopList=true, this.checkedOff=false, this.isHeader=false, this.isHeaderInputField=false, this.isEntryInputField=false, this.homeIndex=-1, this.supermarketIndex=-1, this.isSubClass=true});
}
