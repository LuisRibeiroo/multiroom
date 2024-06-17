import 'package:auto_injector/auto_injector.dart';

import 'app/(modules)/(shared)/controllers/options_bottom_sheet_controller.dart';
import 'app/(modules)/configs/controllers/configs_page_controller.dart';
import 'app/(modules)/configs/controllers/device_configuration_page_controller.dart';
import 'app/(modules)/home/interactor/home_page_controller.dart';
import 'app/(modules)/scanner/interactor/controllers/scanner_page_controller.dart';

final injector = AutoInjector(
  on: (i) {
    i.addLazySingleton(OptionsBottomSheetController.new);
    i.addLazySingleton(HomePageController.new);
    i.addLazySingleton(ConfigsPageController.new);
    i.addLazySingleton(ScannerPageController.new);
    i.addLazySingleton(DeviceConfigurationPageController.new);
  },
);
