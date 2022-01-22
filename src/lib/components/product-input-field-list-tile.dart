import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'package:shoplist/models/product-input-field.dart';

ListTile productInputFieldListTile(
    ProductInputField entry,
    Function onTextSubmittedCallback,
    Function removeEntryCallback,
) {
    return ListTile(
        key: ValueKey(entry.id),
        title: TextField(
            controller: TextEditingController(
                text: "",
            ),
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.black
            ),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
                hintText: "tap to add new item",
                hintStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12.0,
                    color: Colors.grey,
                )
            ),
            onSubmitted: (submittedText) {
                onTextSubmittedCallback(submittedText);
            },
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        dense: true,
        leading: Wrap(
            children: <Widget>[
                IconButton(
                    padding: EdgeInsets.all(4.0),
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.dehaze),
                ),
                IconButton(
                    padding: EdgeInsets.all(4.0),
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.clear),
                    onPressed: () {
                        removeEntryCallback();
                    }
                ),
            ],
        ),
    );
}
