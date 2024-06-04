import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../interactor/controllers/home_page_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = injector.get<HomePageController>();

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiroom APP'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        scrolledUnderElevation: 0,
      ),
      body: Watch(
        (_) => const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}

class LocalData extends StatelessWidget {
  const LocalData({
    super.key,
    required this.networkName,
    required this.localIp,
  });

  final String networkName;
  final String localIp;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          ListTile(
            title: const Text('Wi-fi'),
            subtitle: Text(networkName),
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: networkName),
                );
              },
            ),
          ),
          const Divider(indent: 12, endIndent: 12),
          ListTile(
            title: const Text('IP local'),
            subtitle: Text(localIp),
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: localIp),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
