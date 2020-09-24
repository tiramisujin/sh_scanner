import 'package:data_connection_checker/data_connection_checker.dart';

String toDouble(String val) {
  if (isNumeric(val)) {
    String str = double.parse(val).toStringAsFixed(2);
    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    Function mathFunc = (Match match) => '${match[1]},';

    return str.replaceAllMapped(reg, mathFunc);
  }

  return "0.00";
}

bool isNumeric(dynamic str) {
  if (str == null) {
    return false;
  }

  return double.tryParse(str) != null;
}

Future<bool> checkInternetConnection() async {
  return await DataConnectionChecker().connectionStatus ==
      DataConnectionStatus.connected;
}
