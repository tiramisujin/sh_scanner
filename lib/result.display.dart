import 'package:flutter/material.dart';
import 'package:commons/commons.dart';

import 'helper.dart';
import 'scanner.dart';
import 'result.query.dart';
import 'result.display.build.dart';

class ResultDisplayPage extends StatefulWidget {
  final String code;

  ResultDisplayPage([this.code]);

  @override
  _ResultDisplayPageState createState() => _ResultDisplayPageState();
}

class _ResultDisplayPageState extends State<ResultDisplayPage> {
  List<Map<String, dynamic>> _resultList = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2 - 25;

    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Result"),
      ),
      body: ListView.separated(
        padding: EdgeInsets.only(bottom: 70.0),
        itemCount: _resultList.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.transparent),
        itemBuilder: (BuildContext context, int index) =>
            draw(_resultList.length - (index + 1)),
      ),
      bottomSheet: ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          buildButton(
              width: width,
              color: Colors.blue[300],
              text: "Scan Now",
              onPressed: scan),
          buildButton(
              width: width,
              color: Colors.yellow[300],
              text: "Clear Results",
              onPressed: clear),
        ],
      ),
    );
  }

  Widget draw(int index) {
    Map<String, dynamic> data = _resultList[index];
    ResultQueryStatus status = _resultList[index]["status"];
    Widget node;

    switch (status) {
      case ResultQueryStatus.SUCCESS:
        node = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildRow(title: "Item Code", value: data["item"]),
          SizedBox(
            height: 20,
          ),
          buildRow(title: "Item Name", value: data["name"]),
          SizedBox(
            height: 20,
          ),
          buildRow(title: "Price", value: toDouble(data["price"])),
          SizedBox(
            height: 20,
          ),
          buildRow(title: "Quantity On Hand", value: data["quantity"]),
        ]);
        break;

      case ResultQueryStatus.FAIL:
        node = Text("Unable to connect to server");
        break;

      case ResultQueryStatus.NO_INTERNET:
        node = Text("No internet connection");
        break;

      case ResultQueryStatus.INVALID_FORMAT:
        node = Text("Data returned is not in correct format");
        break;

      case ResultQueryStatus.ITEM_NOT_FOUND:
        node = Text("Item not found [${data['code']}]");
    }

    return buildCard(node,
        color: (status == ResultQueryStatus.SUCCESS)
            ? Colors.green[200]
            : Colors.red[200]);
  }

  void scan() async {
    String code = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ScannerPage()));

    if (code.trim().isNotEmpty) {
      push(
        context,
        loadingScreen(
          context,
          loadingType: LoadingType.JUMPING,
        ),
      );

      Map<String, dynamic> result = await ResultQuery.code(code);

      setState(() {
        _resultList.add(result);
      });

      pop(context);
    }
  }

  void clear() {
    setState(() {
      _resultList.clear();
    });
  }
}
