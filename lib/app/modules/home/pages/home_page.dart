import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/utils/platform_checker.dart';
import '../../../core/widgets/device_state_indicator.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/selectable_list_view.dart';
import '../../shared/pages/options_menu.dart';
import '../../widgets/icon_title.dart';
import '../interactor/home_page_controller.dart';
import '../widgets/device_info_header.dart';
import '../widgets/disable_all_zones_bottom_sheet.dart';
import '../widgets/summary_zones_list.dart';
import '../widgets/zone_controls.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _controller = injector.get<HomePageController>();
  late TabController _tabControler;

  final visible = false.asSignal();

  void _showDevicesBottomSheet() {
    context.showCustomModalBottomSheet(
      child: Watch(
        (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                const IconTitle(
                  title: "Zonas",
                  icon: Icons.surround_sound_rounded,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        Routefly.pop(context);

                        Routefly.push(
                          routePaths.modules.home.pages.editZones,
                          arguments: {
                            "project": _controller.currentProject.value,
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.edit_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _getDeviceZoneTiles(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChannelsBottomSheet({ZoneModel? zone}) {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: Watch(
        (_) => SelectableListView(
          title: "Canais",
          icon: Icons.music_note,
          options: (zone ?? _controller.currentZone.value).channels,
          onSelect: zone != null
              ? (ChannelModel c) => _controller.setCurrentChannel(c, zone: zone)
              : _controller.setCurrentChannel,
          selectedOption: _controller.currentZone.value.channel,
          onTapEdit: () {
            Routefly.pop(context);

            Routefly.push(
              routePaths.modules.home.pages.editChannels,
              arguments: {
                "project": _controller.currentProject.value,
                "device": _controller.currentDevice.value,
                "zone": _controller.currentZone.value,
              },
            );
          },
        ),
      ),
    );
  }

  void _showEqualizersBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: Watch(
        (_) => SelectableListView(
          title: "Equalizadores",
          icon: Icons.equalizer_rounded,
          options: _controller.equalizers,
          onSelect: _controller.setEqualizer,
          selectedOption: _controller.currentEqualizer.value,
        ),
      ),
    );
  }

  void _showProjectsBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: Watch(
        (_) => SelectableListView(
          title: "Projetos",
          icon: Icons.group_work_rounded,
          options: _controller.projects,
          onSelect: _controller.setProject,
          selectedOption: _controller.currentProject.value,
        ),
      ),
    );
  }

  List<Widget> _getDeviceZoneTiles() {
    final tiles = <Widget>[];

    for (final device in _controller.currentProject.value.devices) {
      for (final zone in device.groupedZones) {
        tiles.add(
          ListTile(
            title: Text(zone.name),
            subtitle: Text(
              device.name,
              style: context.textTheme.labelSmall!.copyWith(color: context.theme.disabledColor),
            ),
            trailing: Visibility(
              visible: zone.id == _controller.currentZone.value.id &&
                  device.serialNumber == _controller.currentDevice.value.serialNumber,
              child: const Icon(Icons.check_rounded),
            ),
            onTap: () {
              _controller.setCurrentZone(zone: zone);
              Routefly.pop(context);
            },
          ),
        );
      }
    }

    return tiles;
  }

  void _showAllZonesOffBottomSheet(BuildContext context) {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: DisableAllZonesBottomSheet(
        onConfirm: _controller.onConfirmDisableAllZones,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    AppLifecycleListener(
      onResume: () {
        if (PlatformChecker.isMobile) {
          _controller.syncLocalData(allDevices: true);
        }
      },
    );

    _tabControler = TabController(
      vsync: this,
      length: 2,
      initialIndex: _controller.expandedViewMode.value ? 1 : 0,
    );

    scheduleMicrotask(() {
      _tabControler.addListener(() {
        setState(() {
          if (_tabControler.index == 0) {
            _controller.setViewMode(expanded: false);
          } else {
            _controller.setViewMode(expanded: true);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: const ValueKey(HomePage),
      onVisibilityChanged: (info) async {
        if (info.visibleFraction == 1) {
          _controller.syncLocalData(allDevices: true);

          _controller.setPageVisible(true);
        } else {
          _controller.setPageVisible(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: [
              Watch(
                (_) => InkWell(
                  onTap: _showProjectsBottomSheet,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _controller.currentProject.value.name,
                        ),
                      ),
                      8.asSpace,
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Watch(
                (_) => AnimatedSwitcher(
                  duration: Durations.short4,
                  child: Visibility(
                    key: ValueKey("DeviceZonesPower_${_controller.allDevicesOnline.value}"),
                    visible: _controller.anyZoneOnInProject.value,
                    child: IconButton(
                      onPressed: () => _showAllZonesOffBottomSheet(context),
                      icon: Icon(
                        Icons.power_settings_new_rounded,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Watch(
                (_) => DeviceStateIndicator(
                  value: _controller.allDevicesOnline.value,
                ),
              ),
              // const VerticalDivider(),
              // Watch(
              //   (_) => IconButton(
              //     onPressed: () {
              //       visible.value = !visible.value;
              //     },
              //     icon: Icon(
              //       Icons.search_rounded,
              //       color: context.colorScheme.primary,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        drawer: OptionsMenu(
          pageState: _controller.state,
          onFactoryRestore: () async {
            final success = await _controller.onFactoryRestore();

            if (success) {
              toastification.show(
                type: ToastificationType.success,
                style: ToastificationStyle.minimal,
                autoCloseDuration: const Duration(seconds: 2),
                title: const Text("Dispositivo restaurado"),
                closeOnClick: true,
              );
            }
          },
        ),
        body: LoadingOverlay(
          key: const ValueKey("HomePage_Key"),
          state: _controller.state,
          currentIp: _controller.currentDevice.value.ip,
          onTap: () {
            toastification.dismissAll(delayForAnimation: false);
            toastification.show(
              title: const Text("Dispositivo offline"),
              description: const Text("Os controles serão liberados quando houver nova comunicação"),
              autoCloseDuration: const Duration(seconds: 2),
              style: ToastificationStyle.minimal,
              type: ToastificationType.info,
              closeOnClick: true,
            );
          },
          onSuccessState: () {
            _controller.syncLocalData(allDevices: true);
          },
          child: SafeArea(
            child: Watch(
              (_) => TabBarView(
                controller: _tabControler,
                children: [
                  RefreshIndicator.adaptive(
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    key: PageStorageKey("$SummaryZonesList"),
                    onRefresh: () => _controller.syncLocalData(allDevices: true),
                    child: SingleChildScrollView(
                      child: Watch(
                        (_) => Column(
                          children: [
                            AnimatedSize(
                              duration: Durations.medium1,
                              child: Container(
                                color: Colors.green,
                                height: visible.value ? 80 : 0,
                              ),
                            ),
                            SummaryZonesList(
                              devices: _controller.currentProject.value.devices,
                              zones: _controller.projectZones.value,
                              onChangeActive: _controller.setZoneActive,
                              onChangeChannel: (zone) {
                                _controller.setCurrentZone(zone: zone);
                                _showChannelsBottomSheet(zone: zone);
                              },
                              onChangeVolume: _controller.setVolume,
                              onTapZone: (zone) {
                                _controller.setCurrentZone(zone: zone);
                                _tabControler.animateTo(1);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  RefreshIndicator.adaptive(
                    key: PageStorageKey("$DeviceInfoHeader"),
                    onRefresh: () => _controller.syncLocalData(allDevices: true),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DeviceInfoHeader(
                            project: _controller.currentProject.value,
                            deviceName: _controller.currentDevice.value.name,
                            currentZone: _controller.currentZone.value,
                            currentChannel: _controller.currentZone.value.channel,
                            onChangeActive: _controller.setZoneActive,
                            onChangeDevice: _showDevicesBottomSheet,
                            onChangeChannel: _showChannelsBottomSheet,
                            onChangeProject: _showProjectsBottomSheet,
                          ),
                          12.asSpace,
                          ZoneControls(
                            currentZone: _controller.currentZone.value,
                            currentEqualizer: _controller.currentEqualizer.value,
                            equalizers: _controller.equalizers.value,
                            onChangeBalance: _controller.setBalance,
                            onChangeVolume: _controller.setVolume,
                            onUpdateFrequency: _controller.setFrequency,
                            onChangeEqualizer: _showEqualizersBottomSheet,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // floatingActionButtonLocation: _controller.expandedViewMode.watch(context)
        //     ? FloatingActionButtonLocation.miniStartFloat
        //     : FloatingActionButtonLocation.endFloat,
        // floatingActionButton: _controller.expandedViewMode.watch(context)
        //     ? FloatingActionButton.small(
        //         child: const Icon(Icons.arrow_back_rounded),
        //         onPressed: () => _tabControler.animateTo(0),
        //       )
        //     : FloatingActionButton.small(
        //         child: const Icon(Icons.music_note),
        //         onPressed: () => {},
        //       ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
        floatingActionButton: _controller.expandedViewMode.watch(context)
            ? FloatingActionButton.small(
                child: const Icon(Icons.arrow_back_rounded),
                onPressed: () => _tabControler.animateTo(0),
              )
            : null,
      ),
    );
  }
}
