import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'app/(modules)/devices/ui/pages/device_info_page.dart';
import 'device_model.dart';
import 'mocks.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset("assets/logo.png"),
        ),
      ),
      body: Watch(
        (context) => AnimatedSwitcher(
          duration: Durations.medium3,
          child: devicesList.isEmpty
              ? Center(
                  key: const ValueKey("empty"),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const Icon(
                        Icons.device_unknown_rounded,
                        size: 120,
                      ),
                      Text(
                        'Voce ainda não possui dispositivos',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              Icons.turn_left_outlined,
                              size: 80,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color!
                                  .withAlpha(80),
                            ),
                          ),
                          const SizedBox(width: 80),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                )
              : ListView.builder(
                  key: const ValueKey("list"),
                  itemCount: devicesList.length,
                  itemBuilder: (context, index) {
                    final device = devicesList[index];

                    return ListTile(
                      title: Text(device.name),
                      subtitle: Text(device.zone),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DeviceInfoPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => devicesList.add(DeviceModel.empty()),
        tooltip: 'Adicionar dispositivo',
        child: const Icon(Icons.add_to_queue_rounded),
      ),
    );
  }
}
