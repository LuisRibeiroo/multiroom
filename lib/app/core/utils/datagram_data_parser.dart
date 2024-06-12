import 'dart:convert';

abstract class DatagramDataParser {
  static (String serialNumber, String firmware) getSerialAndFirmware(String data) {
    String serialNumber = "";
    String firmware = "";

    switch (jsonDecode(data)) {
      case {"serialNumber": final value}:
        serialNumber = value;

      case {"fwVersion": final value}:
        firmware = value;
    }

    return (serialNumber, firmware);
  }
}
