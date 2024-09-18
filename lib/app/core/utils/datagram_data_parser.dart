import 'dart:typed_data';

abstract class DatagramDataParser {
  static (String serialNumber, String firmware) getSerialAndFirmware(Uint8List data) {
    String serialNumber = String.fromCharCodes(data.sublist(29, 45));
    final firmware = ((data.sublist(45, 46).toList().first + (data.sublist(46, 47).toList().first * 256)) / 1000);
    final numbersOnly = firmware.toString().replaceAll(".", "");
    final formatted = "${numbersOnly.substring(0, 2)}.${numbersOnly.substring(2)}";

    return (serialNumber, formatted);
  }
}
