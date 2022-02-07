import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/screens/needs.dart';
import 'package:shoplist/screens/next-visit.dart';
import 'package:shoplist/screens/route.dart';
import 'package:shoplist/models/appdata.dart';
import 'package:shoplist/util/fs.dart';
import 'package:shoplist/util/misc.dart';

class HomeScreen extends StatefulWidget {
    AppData appData;

    HomeScreen(this.appData);

    @override
    HomeScreenState createState() => HomeScreenState(appData);
}

class HomeScreenState extends State<HomeScreen> {
    AppData appData;

    HomeScreenState(this.appData);

    int selectedPageIndex = 0;

    @override
    Widget build(BuildContext context) {

        List <Widget> widgetOptions = <Widget>[
            NeedsScreen(appData),
            NextVisitScreen(appData),
            RouteScreen(appData)
        ];

        return Scaffold(
            body: Center(
                child: widgetOptions.elementAt(selectedPageIndex)
            ),
            bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.subject),
                        label: 'Needs',
                    ),
                    BottomNavigationBarItem(
                        // icon: Icon(Icons.directions_NextVisit),
                        icon: Icon(Icons.shopping_cart),
                        label: 'Next Visit',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.compare_arrows),
                        // icon: Icon(Icons.format_list_bulleted),
                        label: 'Route',
                    ),
                ],
                currentIndex: selectedPageIndex,
                selectedItemColor: Colors.amber[800],
                onTap: (index) {
                    setState(() {
                        selectedPageIndex = index;
                    });
                }
            ),
        );
    }
}
