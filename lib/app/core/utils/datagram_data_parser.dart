import 'dart:typed_data';

abstract class DatagramDataParser {
  static (String serialNumber, String firmware) getSerialAndFirmware(Uint8List data) {
    String serialNumber = String.fromCharCodes(data.sublist(29, 45));
    String firmware = data.sublist(46, 48).join(".");

    return (serialNumber, firmware);
  }
}
