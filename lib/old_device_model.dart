class OldDeviceModel {
  const OldDeviceModel({
    required this.name,
    required this.zone,
    required this.input,
    required this.volume,
    required this.balance,
    required this.equalizer,
  });

  factory OldDeviceModel.empty() {
    return const OldDeviceModel(
      name: 'Dispositivo Teste',
      zone: 'Zona 1.0 M1',
      input: 'Input 1',
      volume: 100,
      balance: 0,
      equalizer: [],
    );
  }

  final String name;
  final String zone;
  final String input;
  final int volume;
  final int balance;
  final List<int> equalizer;
}
