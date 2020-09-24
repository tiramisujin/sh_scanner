import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'helper.dart';
import 'constants.dart';

enum ResultQueryStatus {
  SUCCESS,
  NO_INTERNET,
  FAIL,
  INVALID_FORMAT,
  ITEM_NOT_FOUND
}

class ResultQuery {
  static Map<String, dynamic> _result = {};

  static Future<Map<String, dynamic>> code(String code) async {
    _result = {};
    // code = "50010004";

    if (await checkInternetConnection()) {
      await _run(code);
      _result["code"] = code;

      if (!_result.containsKey("status")) {
        _result["status"] = ResultQueryStatus.SUCCESS;
      }
    } else {
      _result["status"] = ResultQueryStatus.NO_INTERNET;
    }

    return _result;
  }

  static Future<void> _run(String code) async {
    await _get(API_GET_DETAIL + code, _parseDetail);
    if (_result.containsKey("status")) {
      return;
    }
    await _get(API_GET_STOCK.replaceFirst("{id}", _result["id"]), _parseStock);
  }

  static Future<void> _get(String url, Function callback) async {
    var response = await http.get(url, headers: API_HEADERS);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      callback(jsonResponse);
    } else {
      print("Failed to get item details.");
      _result["status"] = ResultQueryStatus.FAIL;
    }
  }

  static void _parseDetail(dynamic json) {
    _parse(json, 'items', (data) {
      _result["id"] = data["id"].toString();
      _result["item"] = data["itemCode"].toString();
      _result["name"] = data["itemName"].toString();
      _result["price"] = data["salesPrice"].toString();
    });
  }

  static void _parseStock(dynamic json) {
    _parse(json, 'stocks', (data) {
      _result["quantity"] = data["onhandQuantity"].toString();
    });
  }

  static void _parse(dynamic json, String type, Function callback) {
    try {
      if (json["data"][type].length <= 0) {
        _result["status"] = ResultQueryStatus.ITEM_NOT_FOUND;
        return;
      }

      callback(json["data"][type][0]);
    } catch (e) {
      _result["status"] = ResultQueryStatus.INVALID_FORMAT;
    }
  }
}
