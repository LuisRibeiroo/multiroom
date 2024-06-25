import 'package:equatable/equatable.dart';

import 'device_model.dart';

class ProjectModel extends Equatable {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.devices,
  });

  const ProjectModel.empty()
      : this(
          id: '',
          name: '',
          devices: const [],
        );

  factory ProjectModel.builder({
    required String name,
  }) {
    return ProjectModel(
      id: "P${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      devices: const [],
    );
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'],
      name: map['name'],
      devices: List<DeviceModel>.from(
        map['devices']?.map((x) => DeviceModel.fromMap(x)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'devices': devices.map((x) => x.toMap()).toList(),
    };
  }

  final String id;
  final String name;
  final List<DeviceModel> devices;

  ProjectModel copyWith({
    String? id,
    String? name,
    List<DeviceModel>? devices,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      devices: devices ?? this.devices,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        devices,
      ];
}
