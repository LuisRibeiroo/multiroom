enum DeviceType {
  master,
  slave1,
  slave2;

  static fromString(String value) => switch (value.toLowerCase()) {
        "master" => master,
        "slave1" => slave1,
        "slave2" => slave2,
        _ => master,
      };
}
