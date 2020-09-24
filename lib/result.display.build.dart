import 'package:flutter/material.dart';

Widget buildButton(
    {double width: 200.0,
    Color color: Colors.grey,
    String text: "",
    Function onPressed}) {
  return ButtonTheme(
    minWidth: width,
    padding: EdgeInsets.symmetric(vertical: 5.0),
    child: RaisedButton(
      color: color,
      child: Text(text),
      onPressed: onPressed,
    ),
  );
}

Widget buildRow({String title, String value = ""}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title + ":", style: TextStyle(fontSize: 11)),
      Text(value),
    ],
  );
}

Widget buildCard(Widget node, {Color color = Colors.white}) {
  return ListTile(
      title: Card(
          color: color,
          child: Padding(padding: EdgeInsets.all(20.0), child: node)));
}
