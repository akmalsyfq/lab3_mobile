import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:rent_a_room/roomdetails.dart';
//import 'package:rent_a_room/room.dart';

import 'config.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List _productList = [];
  String textCenter = "Loading...";
  late double screenHeight, screenWidth;
  late ScrollController _scrollController;
  int scrollcount = 5;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          centerTitle: true,
          title: const Text(
            'BellaCosa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: _productList.isEmpty
            ? Center(
                child: Text(textCenter,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)))
            : Column(
                children: [
                  Flexible(
                      flex: 10,
                      child: GridView.count(
                          crossAxisCount: 2,
                          controller: _scrollController,
                          children: List.generate(scrollcount, (index) {
                            return Card(
                                child: InkWell(
                              onTap: () => {},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: screenHeight / 5,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          image: NetworkImage(
                                            (Config.server +
                                                "/bellacosa/images/product/" +
                                                _productList[index]["code"] +
                                                ".png"),
                                          ),
                                        ),
                                      )),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        6.0, 0.0, 6.0, 6.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_productList[index]["name"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                          const Icon(
                                            Icons.favorite_border,
                                          ),
                                        ]),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        6.0, 0.0, 6.0, 6.0),
                                    child: Row(children: [
                                      Text("RM" + _productList[index]["price"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const Spacer(),
                                      const Icon(
                                        Icons.star_border_rounded,
                                        size: 20,
                                      ),
                                      Text(
                                        _productList[index]["rate"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ));
                          })))
                ],
              ),
      ),
    );
  }

  Future<void> _loadProducts() async {
    http.post(Uri.parse(Config.server + "/bellacosa/php/loadproducts.php"),
        body: {}).then((response) {
      if (response.statusCode == 200 && response.body != "failed") {
        var extractdata = json.decode(response.body);
        setState(() {
          _productList = extractdata["products"];
          print(_productList);
          if (scrollcount >= _productList.length) {
            scrollcount = _productList.length;
          }
        });
      }
    });
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        if (_productList.length > scrollcount) {
          scrollcount = scrollcount + 10;
          if (scrollcount >= _productList.length) {
            scrollcount = _productList.length;
          }
        }
      });
    }
  }
}
