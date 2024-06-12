import 'package:auto_injector/auto_injector.dart';

import 'app/(modules)/devices/interactor/controllers/device_configuration_page_controller.dart';
import 'app/(modules)/devices/interactor/controllers/device_demo_page_controller.dart';
import 'app/(modules)/home/interactor/controllers/home_page_controller.dart';
import 'app/(modules)/scanner/interactor/controllers/scanner_page_controller.dart';

final injector = AutoInjector(
  on: (injector) {
    injector.addLazySingleton(DeviceDemoPageController.new);
    injector.addLazySingleton(HomePageController.new);
    injector.addInstance(ScannerPageController());
    injector.addInstance(DeviceConfigurationPageController());
  },
);
