import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:multiroom/app/modules/home/widgets/summary_zones_list.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/selectable_list_view.dart';
import '../../shared/pages/options_bottom_sheet.dart';
import '../widgets/device_info_header.dart';
import '../widgets/zone_controls.dart';
import '../../widgets/icon_title.dart';
import '../interactor/home_page_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = injector.get<HomePageController>();

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

  void _showChannelsBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: Watch(
        (_) => SelectableListView(
          title: "Canais",
          icon: Icons.input_rounded,
          options: _controller.channels,
          onSelect: _controller.setCurrentChannel,
          selectedOption: _controller.currentChannel.value,
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
  Widget build(BuildContext context) {
    return Watch(
      (_) => VisibilityDetector(
        key: const ValueKey(HomePage),
        onVisibilityChanged: (info) async {
          if (info.visibleFraction == 1) {
            await _controller.syncLocalData();
          }
        },
        child: LoadingOverlay(
          state: _controller.state,
          currentIp: _controller.currentDevice.value.ip,
          child: Scaffold(
            appBar: AppBar(
              leading: Image.asset("assets/logo.png"),
              title: InkWell(
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
              actions: [
                SizedBox(
                  width: 72,
                  child: AnimatedToggleSwitch.dual(
                    current: _controller.expandedMode.value,
                    first: false, second: true,
                    onChanged: (_) => _controller.toggleExpandedMode(),
                    height: 32,
                    indicatorSize: const Size.fromWidth(26),
                    // textBuilder: (value) => Text(
                    //   value ? "Full" : "Resumo",
                    //   style: context.textTheme.titleSmall,
                    // ),
                    iconBuilder: (value) => Icon(
                      value ? Icons.zoom_out_map_rounded : Icons.zoom_in_map_rounded,
                      color: context.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
                8.asSpace,
                // AnimatedSwitcher(
                //   duration: Durations.short4,
                //   child: IconButton(
                //     key: ValueKey(_controller.expandedMode.value),
                //     onPressed: _controller.toggleExpandedMode,
                //     icon: Icon(_controller.expandedMode.value ? Icons.unfold_less_rounded : Icons.unfold_more_rounded),
                //   ),
                // ),
                IconButton(
                  onPressed: () => OptionsMenu.showOptionsBottomSheet(
                    context,
                    state: _controller.state,
                  ),
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  child: AnimatedSwitcher(
                    key: ValueKey("Switcher${_controller.expandedMode.value}"),
                    duration: Durations.short4,
                    child: _controller.expandedMode.value
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DeviceInfoHeader(
                                showProjectsButton: _controller.hasMultipleProjects.value,
                                project: _controller.currentProject.value,
                                deviceName: _controller.currentDevice.value.name,
                                currentZone: _controller.currentZone.value,
                                currentChannel: _controller.currentChannel.value,
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
                          )
                        : SummaryZonesList(
                            zones: _controller.currentDevice.value.groupedZones,
                            onChangeActive: _controller.setZoneActive,
                            onChangeChannel: _showChannelsBottomSheet,
                            onChangeVolume: _controller.setVolume,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
