import 'dart:typed_data';

String asciiToHex(String asciiStr) {
  List<int> chars = asciiStr.codeUnits;
  StringBuffer hex = StringBuffer();
  for (int ch in chars) {
    hex.write(ch.toRadixString(16).padLeft(2, '0'));
  }
  return hex.toString();
}

abstract class DatagramDataParser {
  static (String serialNumber, String firmware, String macAddress) getSerialMacAndFirmware(Uint8List data) {
    String serialNumber = String.fromCharCodes(data.sublist(29, 45));
    String macAddress = asciiToHex(String.fromCharCodes(data.sublist(23, 26)));
    final firmware = ((data.sublist(45, 46).toList().first + (data.sublist(46, 47).toList().first * 256)));
    final numbersOnly = firmware.toString().replaceAll(".", "");
    final formatted = "${numbersOnly.substring(0, 2)}.${numbersOnly.substring(2).padLeft(2, "0")}";

    return (serialNumber, formatted, macAddress);
  }
}
