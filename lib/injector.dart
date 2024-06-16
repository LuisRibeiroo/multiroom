import 'package:auto_injector/auto_injector.dart';

import 'app/(modules)/configs/controllers/device_configuration_page_controller.dart';
import 'app/(modules)/home/interactor/device_demo_page_controller.dart';
import 'app/(modules)/configs/controllers/configs_page_controller.dart';
import 'app/(modules)/scanner/interactor/controllers/scanner_page_controller.dart';

final injector = AutoInjector(
  on: (i) {
    i.addLazySingleton(DeviceDemoPageController.new);
    i.addLazySingleton(ConfigsPageController.new);
    i.addLazySingleton(ScannerPageController.new);
    i.addLazySingleton(DeviceConfigurationPageController.new);
  },
);
