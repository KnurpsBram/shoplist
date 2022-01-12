import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/util/misc.dart';

class Entry {

    String id;

    Entry({@required this.id});

    factory Entry.fromJson(Map<String, dynamic> json) {
        switch (json['classType']) {
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

class ProductEntry extends Entry {
    String text;
    bool isCheckedOff;

    ProductEntry({@required String id, @required this.text, this.isCheckedOff=false}) : super(id: id);

    factory ProductEntry.fromJson(Map<String, dynamic> attributes) {
        return ProductEntry(
            id: attributes["id"],
            text: attributes['text'],
            isCheckedOff: attributes["isCheckedOff"]
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': 'ProductEntry',
            'attributes': {
                'id': super.id,
                'text': text,
                'isCheckedOff': isCheckedOff
            }
        };
    }

    void toggleCheckBox() {
        isCheckedOff = !isCheckedOff;
    }
}

class HeaderEntry extends Entry {
    String text;

    HeaderEntry({@required String id, @required this.text}) : super(id: id);

    factory HeaderEntry.fromJson(Map<String, dynamic> attributes) {
        return HeaderEntry(
            id: attributes["id"],
            text: attributes["text"]
        );
    }

    Map<String, dynamic> toJson() {
          return {
            'classType': "HeaderEntry",
            'attributes': {
                'id': super.id,
                'text': text
            }
        };
    }
}

class ProductInputField extends Entry {
    ProductInputField({@required String id}) : super(id: id);

    factory ProductInputField.fromJson(Map<String, dynamic> attributes) {
        return ProductInputField(
            id: attributes['id']
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': "ProductInputField",
            "attributes": {
                'id': super.id
            }
        };
    }
}

class HeaderInputField extends Entry {
    HeaderInputField({@required String id}) : super(id: id);

    factory HeaderInputField.fromJson(Map<String, dynamic> attributes) {
        return HeaderInputField(
            id: attributes['id']
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'classType': "HeaderInputField",
            "attributes": {
                'id': super.id
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
