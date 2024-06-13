enum DeviceType {
  master,
  slave;

  static fromString(String value) => switch (value.toLowerCase()) {
        "master" => master,
        "slave" => slave,
        _ => master,
      };
}
