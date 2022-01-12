import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/models/shop-list-entry.dart';
import 'package:shoplist/util/fs.dart';
import 'package:shoplist/util/misc.dart';

class AppData{
    /// All information that must persist between closing and opening the app
    ///
    /// The AppData object can be mapped to json-formatted string and stored on the device.
    /// It can be restored from such a file on the device as well.
    ///
    /// There's two major attributes; needsList and routeList
    /// The needsList is the shopping list the user crafts at home.
    ///   It consists of all the products he or she might need.
    ///   The user can toggle each product to cross it off the list (without hard-removing it)
    ///   The user can add structure by adding headers ("this is what I need for tuesday", "this is what I need for that pie i want to bake"), purely for bookkeeping
    /// The routeList is the order in which the products appear if the user follows his or her favourite route
    ///   We're not going to attempt to find the shortest route through the supermarket based on product locations
    ///   That's a travelling salesman problem, which is out of scope for this simple app
    ///   We assume the user always walks the same route through the supermarket regardless of what items he or she needs
    ///
    /// Each entry in the needsList has a uuid (universally unique identifier) because it needs that to be reorderable
    /// The name is not the uuid, because the user might enter 'tomatoes' twice, for example
    /// In the routeList the name can be the uuid, because we won't allow adding the same entry twice there

    // TODO: Can't move AppData to a different file because it will throw errors like 'appdata.store()' is not defined and such

    static final AppData _appData = new AppData._internal();

    List needsList = [
        HeaderEntry(id: Uuid().v1(), text: "Monday"),
        ProductEntry(id: Uuid().v1(), text: "Pasta (farfalle)"),
        ProductEntry(id: Uuid().v1(), text: "Tomatoes"),
        HeaderEntry(id: Uuid().v1(), text: "Tuesday"),
        ProductEntry(id: Uuid().v1(), text: "Rice"),
        ProductEntry(id: Uuid().v1(), text: "2 Broccoli"),
        HeaderInputField(id: Uuid().v1()),
        ProductInputField(id: Uuid().v1()),
    ];

    List routeList = [
        "bananas",
        "tomatoes",
        "broccoli",
        "rice",
        "pasta",
        "ice cream",
        ""
    ];

    void fromJson(Map<String, dynamic> json) {
      needsList = json["needsList"].map<Entry>((x) => Entry.fromJson(x)).toList();
      routeList = json["routeList"];
    }

    Map<String, dynamic> toJson() {
      return {
        "needsList": needsList.map((x) => x.toJson()).toList(),
        "routeList": routeList,
      };
    }

    Future<void> store() async {
        Map<String, dynamic> json = toJson();
        // jsonPrettyPrint(json); // for debugging
        writeAppDataString(jsonEncode(json));
        print("Done writing appData to disk");
    }

    Future<void> load() async {
        return loadAppDataString().then((String jsonString) {
            Map<String, dynamic> json = jsonDecode(jsonString);
            // jsonPrettyPrint(json); // for debugging
            fromJson(json);
            print("Done loading appData from disk");
        });
    }

    // void moveProductInputFieldBelowMeInNeedsList(Entry entry) {
    //     appData.needsList = reOrderList(
    //         appData.needsList,
    //         appData.needsList.indexWhere((ele) => ele is ProductEntryField), // oldIndex
    //         appData.needsList.indexOf(entry) + 1, // newIndex
    //     )
    // }
    //
    // void moveProductInputFieldBelowMeInOrderList(Entry entry) {
    //     appData.routeList = reOrderList(
    //         appData.routeList,
    //         appData.routeList.indexWhere((ele) => ele == ""), // oldIndex
    //         appData.routeList.indexOf(entry) + 1, // newIndex
    //     )
    // }

    factory AppData() {
        return _appData;
    }

    AppData._internal();
}
