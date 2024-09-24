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
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/selectable_list_view.dart';
import '../../shared/pages/options_bottom_sheet.dart';
import '../../widgets/icon_title.dart';
import '../interactor/home_page_controller.dart';
import '../widgets/device_info_header.dart';
import '../widgets/summary_zones_list.dart';
import '../widgets/zone_controls.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _controller = injector.get<HomePageController>();
  late TabController _tabControler;

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
                        ).then((_) => _controller.syncLocalData());
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
          icon: Icons.input_rounded,
          options: _controller.channels,
          onSelect: zone != null
              ? (ChannelModel c) => _controller.setCurrentChannel(c, zone: zone)
              : _controller.setCurrentChannel,
          selectedOption: _controller.currentZone.value.channel,
          onTapEdit: () {
            Routefly.pop(context);

            Routefly.push(
              routePaths.modules.home.pages.editChannels,
              arguments: {
                "device": _controller.currentDevice.value,
                "zone": _controller.currentZone.value,
              },
            ).then((_) => _controller.syncLocalData());
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
              _controller.setCurrentDeviceAndZone(device, zone);
              Routefly.pop(context);
            },
          ),
        );
      }
    }

    return tiles;
  }

  @override
  void initState() {
    super.initState();

    _tabControler = TabController(
      vsync: this,
      length: 2,
      initialIndex: _controller.expandedViewMode.value ? 1 : 0,
    );

    _tabControler.addListener(() {
      if (_tabControler.index == 0) {
        _controller.setViewMode(expanded: false);
      } else {
        _controller.setViewMode(expanded: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => VisibilityDetector(
        key: const ValueKey(HomePage),
        onVisibilityChanged: (info) async {
          if (info.visibleFraction == 1) {
            await _controller.syncLocalData(readAllZones: true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Image.asset("assets/logo.png"),
            title: Row(
              children: [
                InkWell(
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
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => OptionsMenu.showOptionsBottomSheet(
                  context,
                  state: _controller.state,
                ),
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
            // bottom: TabBar(
            //   indicatorSize: TabBarIndicatorSize.tab,
            //   controller: _tabControler,
            //   tabs: const [
            //     Tab(
            //       height: 48,
            //       text: 'Resumo',
            //       icon: Icon(Icons.list_rounded),
            //     ),
            //     Tab(
            //       height: 48,
            //       text: 'Detalhe',
            //       icon: Icon(Icons.search_rounded),
            //     ),
            //   ],
            // ),
          ),
          body: LoadingOverlay(
            key: const ValueKey("HomePage_Key"),
            state: _controller.state,
            currentIp: _controller.currentDevice.value.ip,
            onTap: () => toastification.show(
              title:
                  const Text("O dispositivo está offline. Os controles serão liberados quando houver nova comunicação"),
              autoCloseDuration: const Duration(seconds: 3),
              style: ToastificationStyle.minimal,
              type: ToastificationType.info,
            ),
            child: SafeArea(
              child: Watch(
                (_) => TabBarView(
                  controller: _tabControler,
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18),
                        child: SummaryZonesList(
                          devices: _controller.currentProject.value.devices,
                          zones: _controller.projectZones.value,
                          onChangeActive: _controller.setZoneActive,
                          onChangeChannel: ({ZoneModel? zone}) {
                            _controller.setCurrentZone(zone: zone!);
                            _showChannelsBottomSheet(zone: zone);
                          },
                          onChangeVolume: _controller.setVolume,
                          onTapZone: (zone) {
                            _tabControler.animateTo(1);
                            _controller.setCurrentZone(zone: zone);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DeviceInfoHeader(
                              isDeviceActive: _controller.currentDevice.value.active,
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
          floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
          floatingActionButton: _tabControler.index == 1
              ? FloatingActionButton.small(
                  child: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    _tabControler.animateTo(0);
                    setState(() {});
                  })
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
