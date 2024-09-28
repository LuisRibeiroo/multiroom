import 'package:auto_injector/auto_injector.dart';

import 'app/core/interactor/controllers/device_monitor_controller.dart';
import 'app/core/interactor/controllers/loading_overlay_controller.dart';
import 'app/modules/configs/controllers/configs_page_controller.dart';
import 'app/modules/configs/controllers/device_configuration_page_controller.dart';
import 'app/modules/home/interactor/edit_channels_page_controller.dart';
import 'app/modules/home/interactor/edit_zones_page_controller.dart';
import 'app/modules/home/interactor/home_page_controller.dart';
import 'app/modules/scanner/interactor/controllers/scanner_page_controller.dart';
import 'app/modules/shared/controllers/import_data_page_controller.dart';
import 'app/modules/shared/controllers/options_bottom_sheet_controller.dart';

final injector = AutoInjector(
  on: (i) {
    i.addSingleton(DeviceMonitorController.new);
    i.add(OptionsBottomSheetController.new);
    i.add(ImportDataPageController.new);
    i.add(EditChannelsPageController.new);
    i.add(EditZonesPageController.new);
    i.add(LoadingOverlayController.new);
    i.add(ScannerPageController.new);
    i.add(ConfigsPageController.new);
    i.addLazySingleton(HomePageController.new);
    i.addLazySingleton(DeviceConfigurationPageController.new);
  },
);
