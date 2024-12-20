import 'dart:typed_data';

String _asciiToHex(String asciiStr) {
  List<int> chars = asciiStr.codeUnits;
  StringBuffer hex = StringBuffer();
  for (int ch in chars) {
    hex.write(ch.toRadixString(16).padLeft(2, '0'));
  }
  return hex.toString();
}

abstract class DatagramDataParser {
  static (String serialNumber, String firmware, String macAddress) getSerialMacAndFirmware(Uint8List data) {
    final serialNumber = String.fromCharCodes(data.sublist(29, 45));
    final macAddress = _asciiToHex(String.fromCharCodes(data.sublist(23, 26)));
    
    final firmware = ((data.sublist(45, 46).toList().first + (data.sublist(46, 47).toList().first * 256)));
    final numbersOnly = firmware.toString().replaceAll(".", "");
    final formatted = "${numbersOnly.substring(0, 1)}.${numbersOnly.substring(1)}";

    return (serialNumber, formatted, macAddress);
  }
}
