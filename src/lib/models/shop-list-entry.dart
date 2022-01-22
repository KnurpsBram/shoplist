import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/util/misc.dart';
import 'package:shoplist/models/appdata.dart';

class Entry {

    // String id;
    // String id = Uuid().v1();

    // Entry({@required this.id});
    // Entry();

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

class RouteEntry extends Entry {
    String text;

    // String my_uuid = Uuid().v1();
    // RouteEntry({@required String id, @required this.text}) : super(id: id);
    // RouteEntry({@required this.text}) : super(id: id);
    RouteEntry({@required this.text});

    String id = Uuid().v1();

    factory RouteEntry.fromJson(Map<String, dynamic> attributes) {
        return RouteEntry(
            // id: attributes["id"],
            text: attributes['text'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': 'RouteEntry',
            'attributes': {
                // 'id': super.id,
                'text': text,
            }
        };
    }
}

class ProductEntry extends Entry {
    String text;
    bool isCheckedOff;

    // String my_uuid = Uuid().v1();
    // ProductEntry({@required String id, @required this.text, this.isCheckedOff=false}) : super(id: id);
    // ProductEntry({@required this.text, this.isCheckedOff=false}) : super(id: id);
    ProductEntry({@required this.text, this.isCheckedOff=false});

    String id = Uuid().v1();

    String reducedProductName() => reduceProductName(text);

    factory ProductEntry.fromJson(Map<String, dynamic> attributes) {
        return ProductEntry(
            // id: attributes["id"],
            text: attributes['text'],
            isCheckedOff: attributes["isCheckedOff"]
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': 'ProductEntry',
            'attributes': {
                // 'id': super.id,
                'text': text,
                'isCheckedOff': isCheckedOff
            }
        };
    }
}

class HeaderEntry extends Entry {
    String text;

    // String my_uuid = Uuid().v1();
    // HeaderEntry({@required String id, @required this.text}) : super(id: id);
    // HeaderEntry({@required this.text}) : super(id: id);

    HeaderEntry({@required this.text});

    String id = Uuid().v1();

    factory HeaderEntry.fromJson(Map<String, dynamic> attributes) {
        return HeaderEntry(
            // id: attributes["id"],
            text: attributes["text"]
        );
    }

    Map<String, dynamic> toJson() {
          return {
            'classType': "HeaderEntry",
            'attributes': {
                // 'id': super.id,
                'text': text
            }
        };
    }
}

class ProductInputField extends Entry {
    // ProductInputField({@required String id}) : super(id: id);

    // String id;
    // String my_uuid = Uuid().v1();
    // ProductInputField() : super(id: id);
    ProductInputField();

    String id = Uuid().v1();

    factory ProductInputField.fromJson(Map<String, dynamic> attributes) {
        return ProductInputField(
            // id: attributes['id']
        );
    }

    String text = "";

    Map<String, dynamic> toJson() {
        return {
            'classType': "ProductInputField",
            "attributes": {
                // 'id': super.id
            }
        };
    }
}

class HeaderInputField extends Entry {



    // String my_uuid = Uuid().v1();
    // HeaderInputField({@required String id}) : super(id: id);
    // HeaderInputField() : super(id: id);
    HeaderInputField();

    String id = Uuid().v1();

    factory HeaderInputField.fromJson(Map<String, dynamic> attributes) {
        return HeaderInputField(
            // id: attributes['id']
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': "HeaderInputField",
            "attributes": {
                // 'id': super.id
            }
        };
    }
}

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
