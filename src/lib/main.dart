import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shoplist/screens/home.dart';
import 'package:shoplist/models/appdata.dart';
import 'package:shoplist/models/shop-list-entry.dart';
import 'package:shoplist/util/fs.dart';
import 'package:shoplist/util/misc.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  AppData appData = AppData();

  runApp(MainApp(appData));

}

class MainApp extends StatelessWidget {

    AppData appData;

    MainApp(this.appData);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'ShopList',
            // home  : BottomBarMainBodyWidget(appData)
            home: HomeScreen(appData)
        );
    }
}

// // Show stuff that's always there; the bottom bar and an open window where the main window will go
// class BottomBarMainBodyWidget extends StatefulWidget {
//
//     AppData appData;
//
//     BottomBarMainBodyWidget(this.appData);
//
//     @override
//     _BottomBarMainBodyWidgetState createState() => _BottomBarMainBodyWidgetState(appData);
// }
//
// class _BottomBarMainBodyWidgetState extends State<BottomBarMainBodyWidget> {
//     /// Holds a list of tabs and a bottom bar to let the user switch between tabs
//
//     AppData appData;
//
//     _BottomBarMainBodyWidgetState(this.appData);
//
//     int _selectedPageIndex = 0;
//
//     @override
//     Widget build(BuildContext context) {
//
//         List<Widget> _widgetOptions = <Widget>[
//             HomeList(appData),
//             TripList(appData),
//             SupermarketList(appData)
//         ];
//
//         return Scaffold(
//             body: Center(
//                 child: _widgetOptions.elementAt(_selectedPageIndex),
//             ),
//             bottomNavigationBar: BottomNavigationBar(
//                 items: const <BottomNavigationBarItem>[
//                     BottomNavigationBarItem(
//                         icon: Icon(Icons.home),
//                         label: 'Home',
//                     ),
//                     BottomNavigationBarItem(
//                         icon: Icon(Icons.shopping_cart),
//                         label: 'Trip',
//                     ),
//                     BottomNavigationBarItem(
//                         icon: Icon(Icons.apartment),
//                         label: 'Supermarket',
//                     ),
//                 ],
//                 currentIndex: _selectedPageIndex,
//                 selectedItemColor: Colors.amber[800],
//                 onTap: (index) {
//                     setState(() {
//                         _selectedPageIndex = index;
//                     });
//                 }
//             ),
//         );
//     }
// }
//
// //
// // HOME LIST
// //
// class HomeList extends StatefulWidget {
//
//     AppData appData;
//
//     HomeList(this.appData);
//
//     @override
//     _HomeListState createState() => _HomeListState(appData);
// }
//
// class _HomeListState extends State<HomeList> {
//     /// The page where the user crafts his or her shopping list
//     ///
//     /// The user can add new product entries through a special ProductInputField
//     ///   If the entry has never been seen before it will also be added to supermarketOrder in a trivial position (bottom)
//     ///   When the user reorders the supermarketOrder, it will be remembered forever.
//     ///   Before adding the entry to the supermarketOrder the name is 'reduced'; no numbers, lowercase, ignore parentheses
//     ///   This means that if the user adds '3 Bananas (unripe)' it will be sorted according to the location of 'bananas' in the supermarketOrder
//     /// The user can add headers with the HeaderInputField,
//     ///   the HeaderEntries are only there to make the list more readable for the user and so they have no checkbox
//     /// The user can drag and reorder existing entries
//     /// The user can remove ProductEntries and HeaderEntries
//     /// The user cannot remove ProductEntryFields and HeaderEntryFields
//
//     AppData appData;
//
//     _HomeListState(this.appData);
//
//     @override
//     void initState() {
//         super.initState();
//         appData.load().whenComplete(() {
//           setState(() {});
//         });
//     }
//
//     @override
//     Widget build(BuildContext context) {
//         return Scaffold(
//             appBar: AppBar(
//               title: Text("Home"),
//             ),
//             body: ReorderableListView( // TODO: you need to long-press before reordering which is soooooo slow, make the press time shorter somehow: https://github.com/flutter/flutter/issues/25065
//                 onReorder: (oldIndex, newIndex) {
//                     setState(() {
//                         appData.needsList = reOrderList(appData.needsList, oldIndex, newIndex);
//                         appData.store();
//                     });
//                 },
//                 children: [
//                     for (final entry in appData.needsList) _buildRow(entry)
//                 ]
//             )
//         );
//     }
//
//     Widget _buildRow(Entry entry) {
//
//       if (entry is ProductEntry) { // TODO: is switch-case possible here?
//         return ListTile(
//           key: ValueKey(entry.id),
//           title: TextField(
//             controller: TextEditingController(
//                 text: entry.text,
//             ),
//             style: TextStyle(
//                 fontSize: 20.0,
//                 color: entry.isCheckedOff ? Colors.grey[350] : Colors.black
//             ),
//             decoration: new InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder  : InputBorder.none,
//                 contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//             ),
//             onSubmitted: (productName) {
//                 setState( () {
//                     entry.text = productName;
//                     String reducedProductName = reduceProductName(productName);
//                     if (!appData.routeList.contains(reducedProductName)) {
//                       appData.routeList.add(reducedProductName);
//                     }
//                     appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
//                         appData.needsList,
//                         appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
//                         appData.needsList.indexOf(entry) + 1 // newIndex
//                     );
//                     appData.store();
//                 });
//             },
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           dense: true,
//           leading : Wrap(
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.all(4.0),
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.dehaze),
//               ),
//               IconButton(
//                   padding: EdgeInsets.all(4.0),
//                   constraints: BoxConstraints(),
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                       setState( () {
//                           appData.needsList.remove(entry);
//                           appData.store();
//                       });
//                   }
//               ),
//             ],
//           ),
//           trailing: IconButton(
//             padding: EdgeInsets.all(4.0),
//             constraints: BoxConstraints(),
//             icon: Icon(entry.isCheckedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
//             onPressed: () {
//                 setState( () {
//                     entry.isCheckedOff = !entry.isCheckedOff;
//                     appData.store();
//                 });
//             }
//           )
//         );
//       } else if (entry is ProductInputField) {
//         return ListTile(
//           key: ValueKey(entry.id),
//           title: TextField(
//             controller: TextEditingController(
//                 text: "",
//             ),
//             decoration: new InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder  : InputBorder.none,
//                 contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//                 hintText       : "tap to add new item",
//                 hintStyle      : TextStyle(
//                     fontStyle : FontStyle.italic,
//                     fontSize  : 12.0,
//                     color     : Colors.grey,
//                 )
//             ),
//             onSubmitted: (productName) {
//                 setState( () {
//                     appData.needsList.insert(appData.needsList.indexOf(entry), ProductEntry(id: Uuid().v1(), text: productName));
//                     String reducedProductName = reduceProductName(productName);
//                     if (!appData.routeList.contains(reducedProductName)) {
//                       appData.routeList.add(reducedProductName);
//                     }
//                     appData.store();
//                 });
//             },
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           dense: true,
//           leading : Wrap(
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.all(4.0),
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.dehaze),
//               ),
//               IconButton(
//                   padding: EdgeInsets.all(4.0),
//                   constraints: BoxConstraints(),
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                       setState( () {
//                           appData.needsList.remove(entry);
//                           appData.needsList.add(entry); // this adds it at the end
//                           appData.store();
//                       });
//                   }
//               ),
//             ],
//           ),
//         );
//       } else if (entry is HeaderEntry) {
//         return ListTile(
//           key: ValueKey(entry.id),
//           tileColor: Colors.grey, // TODO: this color looks ugly when the user drags the tile, see https://github.com/flutter/flutter/issues/45799
//           title: TextField(
//             controller: TextEditingController(
//                 text: entry.text,
//             ),
//             style: TextStyle(
//                 fontWeight: FontWeight.bold,
//             ),
//             decoration: new InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder  : InputBorder.none,
//                 contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//             ),
//             onSubmitted: (headerName) {
//                 setState( () {
//                     entry.text = headerName;
//                     appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
//                         appData.needsList,
//                         appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
//                         appData.needsList.indexOf(entry) + 1 // newIndex
//                     );
//                     appData.store();
//                 });
//             },
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           dense: true,
//           leading : Wrap(
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.all(4.0),
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.dehaze),
//               ),
//               IconButton(
//                   padding: EdgeInsets.all(4.0),
//                   constraints: BoxConstraints(),
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                       setState( () {
//                           appData.needsList.remove(entry);
//                           appData.store();
//                       });
//                   }
//               ),
//             ],
//           ),
//         );
//       } else if (entry is HeaderInputField) {
//         return ListTile(
//           key: ValueKey(entry.id),
//           tileColor: Colors.grey, // TODO: this color looks ugly when the user drags the tile, see https://github.com/flutter/flutter/issues/45799
//           title: TextField(
//             controller: TextEditingController(
//                 text: "",
//             ),
//             decoration: new InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder  : InputBorder.none,
//                 contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//                 hintText       : "tap to add new header",
//                 hintStyle      : TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontStyle : FontStyle.italic,
//                     fontSize  : 12.0,
//                 )
//             ),
//             onSubmitted: (text) {
//                 setState( () {
//                     appData.needsList.insert(appData.needsList.indexOf(entry), HeaderEntry(id: Uuid().v1(), text: text));
//                     appData.needsList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
//                         appData.needsList,
//                         appData.needsList.indexWhere((ele) => ele is ProductInputField), // oldIndex
//                         appData.needsList.indexOf(entry) // newIndex
//                     );
//                     appData.store();
//                 });
//             },
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           dense: true,
//           leading : Wrap(
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.all(4.0),
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.dehaze),
//               ),
//               IconButton(
//                   padding: EdgeInsets.all(4.0),
//                   constraints: BoxConstraints(),
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                       setState( () {
//                           appData.needsList.remove(entry);
//                           appData.needsList.add(entry); // this adds it at the end
//                           appData.store();
//                       });
//                   }
//               ),
//             ],
//           ),
//         );
//       } else {
//         print("unsupported entry type");
//       }
//     }
// }
//
// //
// // TRIP LIST
// //
// class TripList extends StatefulWidget {
//
//     AppData appData;
//
//     TripList(this.appData);
//
//     @override
//     _TripListState createState() => _TripListState(appData);
// }
//
// class _TripListState extends State<TripList> {
//     /// The page where the user sees on his or her trip to the supermarket
//     ///
//     /// It consists of the product entries of the homeList, ordered according to the supermarketOrder
//     ///
//     /// There are no headers
//     ///
//     /// TODO: Temporarily disabled reordering this list.
//     ///   When it is enabled, we need a smart way to reorder the supermarketOrder
//     ///   if reordering in triplist is [a, b, c] -> [a, c, b] and supermarketOrder is [a, d, b, c], does it need to become [a, d, c, b] or [a, c, d, b]?
//     ///   There was some logic for this in an older version of the app, see if mimicking that is appropriate
//     ///
//     /// TODO: allow ProductEntryField here, new entry should be added to homeList in a trivial position (bottom?)
//
//     AppData appData;
//
//     _TripListState(this.appData);
//
//     @override
//     void initState() {
//         super.initState();
//         appData.load().whenComplete(() {
//           setState(() {});
//         });
//     }
//
//     @override
//     Widget build(BuildContext context) {
//         var _tripList;
//         _tripList = List.from(appData.needsList.where((x) => (x is ProductEntry)));
//         _tripList.sort((a, b) => appData.routeList.indexOf(reduceProductName(a.text)) - appData.routeList.indexOf(reduceProductName(b.text)) as int);
//
//         return Scaffold(
//             appBar: AppBar(
//               title: Text("Trip (dragging tiles disabled...)"),
//             ),
//             body: ListView( // TODO: ReorderableListView
//                 children: [
//                     for (final entry in _tripList) _buildRow(entry)
//                 ]
//             )
//         );
//     }
//
//     Widget _buildRow(ProductEntry entry) {
//       return ListTile(
//           key: ValueKey(entry.id),
//           title: TextField(
//             controller: TextEditingController(
//                 text: entry.text,
//             ),
//             style: TextStyle(
//                 fontSize: 20.0,
//                 color: entry.isCheckedOff ? Colors.grey[350] : Colors.black
//             ),
//             decoration: new InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder  : InputBorder.none,
//                 contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//             ),
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           dense: true,
//           leading : Wrap(
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.all(4.0),
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.dehaze),
//               ),
//               IconButton(
//                   padding: EdgeInsets.all(4.0),
//                   constraints: BoxConstraints(),
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                       setState( () {
//                           appData.needsList.remove(entry);
//                           appData.store();
//                       });
//                   }
//               ),
//             ],
//           ),
//           trailing: IconButton(
//             padding: EdgeInsets.all(4.0),
//             constraints: BoxConstraints(),
//             icon: Icon(entry.isCheckedOff ? Icons.check_box_outlined : Icons.check_box_outline_blank),
//             onPressed: () {
//                 setState( () {
//                     entry.isCheckedOff = !entry.isCheckedOff;
//                     appData.store();
//                 });
//             }
//           )
//         );
//     }
// }
//
// //
// // SUPERMARKET LIST
// //
// class SupermarketList extends StatefulWidget {
//
//     AppData appData;
//
//     SupermarketList(this.appData);
//
//     @override
//     _SupermarketListState createState() => _SupermarketListState(appData);
// }
//
// class _SupermarketListState extends State<SupermarketList> {
//     /// The page where the user crafts the product order of his or her favourite route through the supermarket
//     ///
//     /// This list should contain every product the user has ever submitted and sorted
//     /// This list contains reduced productnames (lowercased, no numbers, ignore everything between parentheses)
//     /// The string "" is interpreted as the ProductInputField
//     ///
//     /// TODO: the supermarketOrder is a list of strings whereas the homeList is a list of Entry objects, it'd be prettier if supermarketOrder is also a list of Entries (subclasses like SupermarketOrderProductEntry?)
//     /// TODO: allow multiple customizable supermarketorderings (MyLocalJumbo, ThatOneBigAlbertHeijn, etc...)
//
//     AppData appData;
//
//     _SupermarketListState(this.appData);
//
//     @override
//     void initState() {
//         super.initState();
//         appData.load().whenComplete(() {
//           setState(() {});
//         });
//     }
//
//     @override
//     Widget build(BuildContext context) {
//         return Scaffold(
//             appBar: AppBar(
//               title: Text("Full Supermarket Order"),
//             ),
//             body: ReorderableListView(
//                 onReorder: (oldIndex, newIndex) {
//                     setState(() {
//                         appData.routeList = reOrderList(appData.routeList, oldIndex, newIndex);
//                         appData.store();
//                     });
//                 },
//                 children: [
//                     for (final productName in appData.routeList) _buildRow(productName)
//                 ]
//             )
//         );
//     }
//
//     Widget _buildRow(String productName) {
//
//       if (productName != "") { // TODO: is switch-case possible here?
//         return ListTile(
//           key: ValueKey(productName),
//           title: TextField(
//             controller: TextEditingController(
//                 text: productName,
//             ),
//             style: TextStyle(
//                 fontSize   : 20.0,
//                 color      : Colors.black
//             ),
//             decoration: new InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder  : InputBorder.none,
//                 contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//             ),
//             onSubmitted: (text) {
//                 setState( () {
//                     if (!appData.routeList.contains(text)) {
//                         productName = text;
//                     }
//                     appData.routeList = reOrderList( // move the productInputField to below the field that just got something submitted; that's where the user is now looking
//                         appData.routeList,
//                         appData.routeList.indexWhere((ele) => ele == ""), // oldIndex
//                         appData.routeList.indexOf(productName) + 1 // newIndex
//                     );
//                     appData.store();
//                 });
//             },
//
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           dense: true,
//           leading : Wrap(
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.all(4.0),
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.dehaze),
//               ),
//               IconButton(
//                   padding: EdgeInsets.all(4.0),
//                   constraints: BoxConstraints(),
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                       setState( () {
//                           appData.routeList.remove(productName);
//                           appData.store();
//                       });
//                   }
//               ),
//             ],
//           ),
//         );
//       } else if (productName == "") {
//         return ListTile(
//           key: ValueKey("ProductInputField"),
//           title: TextField(
//             controller: TextEditingController(
//                 text: "",
//             ),
//             decoration: new InputDecoration(
//                 border: InputBorder.none,
//                 focusedBorder  : InputBorder.none,
//                 contentPadding : EdgeInsets.only(left: -10, bottom: 0, top: 0, right: 0),
//                 hintText       : "tap to add new item",
//                 hintStyle      : TextStyle(
//                     fontStyle : FontStyle.italic,
//                     fontSize  : 12.0,
//                     color     : Colors.grey,
//                 )
//             ),
//             onSubmitted: (text) {
//                 setState( () {
//                   if (!appData.routeList.contains(text)) {
//                     appData.routeList.insert(appData.routeList.indexOf(""), text);
//                     appData.store();
//                   }
//                 });
//             },
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           dense: true,
//           leading : Wrap(
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.all(4.0),
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.dehaze),
//               ),
//               IconButton(
//                   padding: EdgeInsets.all(4.0),
//                   constraints: BoxConstraints(),
//                   icon: Icon(Icons.clear),
//                   onPressed: () {
//                       setState( () {
//                           appData.routeList.remove("");
//                           appData.routeList.add(""); // this adds it at the end
//                           appData.store();
//                       });
//                   }
//               ),
//             ],
//           ),
//         );
//       } else {
//         print("unsupported type");
//       }
//     }
// }
