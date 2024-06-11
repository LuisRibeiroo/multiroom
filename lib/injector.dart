import 'package:auto_injector/auto_injector.dart';

import 'app/(modules)/devices/interactor/controllers/device_demo_page_controller.dart';

final injector = AutoInjector(
  on: (injector) {
    injector.addLazySingleton(DeviceDemoPageController.new);
  },
);
