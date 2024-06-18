import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../(shared)/pages/options_bottom_sheet.dart';
import '../../../../injector.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/selectable_list_view.dart';
import '../../widgets/device_controls.dart';
import '../../widgets/device_info_header.dart';
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
      isScrollControlled: false,
      child: Watch(
        (_) => SelectableListView(
          options: _controller.localDevices,
          onSelect: _controller.setCurrentDevice,
          selectedOption: _controller.currentDevice.value,
        ),
      ),
    );
  }

  void _showZonesAndGroupsBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: _controller.currentDevice.value.emptyGroups == false,
      child: Watch(
        (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home_filled),
              title: const Text("Zonas"),
              tileColor: context.colorScheme.inversePrimary,
            ),
            Expanded(
              child: SelectableListView(
                options: _controller.zones,
                onSelect: _controller.setCurrentZone,
                selectedOption: _controller.currentZone.value,
              ),
            ),
            Visibility(
              visible: _controller.currentDevice.value.emptyGroups == false,
              child: Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.group_work_rounded),
                      title: const Text("Grupos"),
                      tileColor: context.colorScheme.inversePrimary,
                    ),
                    Flexible(
                      child: SelectableListView(
                        options: _controller.currentDevice.value.groups.whereNot((g) => g.zones.isEmpty).toList(),
                        showSubtitle: true,
                        onSelect: _controller.setCurrentGroup,
                        selectedOption: _controller.currentGroup.value,
                      ),
                    ),
                  ],
                ),
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
          options: _controller.channels,
          onSelect: _controller.setCurrentChannel,
          selectedOption: _controller.currentChannel.value,
        ),
      ),
    );
  }

  void _showEqualizersBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: Watch(
        (_) => SelectableListView(
          options: _controller.availableEqualizers,
          onSelect: _controller.setEqualizer,
          selectedOption: _controller.currentEqualizer.value,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      await _controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => VisibilityDetector(
        key: const ValueKey(HomePage),
        onVisibilityChanged: (info) async {
          if (info.visibleFraction == 1) {
            await _controller.syncLocalDevices();
          }
        },
        child: LoadingOverlay(
          state: _controller.state,
          child: Scaffold(
            appBar: AppBar(
              leading: Image.asset("assets/logo.png"),
              title: const Text('Multiroom'),
              actions: [
                IconButton(
                  onPressed: () => OptionsMenu.showOptionsBottomSheet(context),
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DeviceInfoHeader(
                        deviceName: _controller.currentDevice.value.name,
                        currentZone: _controller.currentZone.value,
                        currentGroup: _controller.currentGroup.value,
                        currentChannel: _controller.currentChannel.value,
                        onChangeDevice: _showDevicesBottomSheet,
                        onChangeZoneGroup: _showZonesAndGroupsBottomSheet,
                        onChangeChannel: _showChannelsBottomSheet,
                      ),
                      12.asSpace,
                      DeviceControls(
                        isGroupSelected: _controller.currentGroup.value.isEmpty == false,
                        currentZone: _controller.currentZone.value,
                        currentEqualizer: _controller.currentEqualizer.value,
                        equalizers: _controller.availableEqualizers.value,
                        onChangeBalance: _controller.setBalance,
                        onChangeVolume: _controller.setVolume,
                        onUpdateFrequency: _controller.setFrequency,
                        onChangeEqualizer: _showEqualizersBottomSheet,
                      ),
                    ],
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
