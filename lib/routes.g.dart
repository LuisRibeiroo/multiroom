// GENERATED FILE. PLEASE DO NOT EDIT THIS FILE!!

import 'package:routefly/routefly.dart';

import 'app/modules/configs/pages/configs_page.dart' as a3;
import 'app/modules/configs/pages/device_configuration_page.dart' as a2;
import 'app/modules/home/pages/home_page.dart' as a0;
import 'app/modules/scanner/pages/scanner_page.dart' as a5;
import 'app/modules/startup/pages/startup_page.dart' as a4;
import 'app/modules/udp/ui/pages/udp_page.dart' as a1;

List<RouteEntity> get routes => [
      RouteEntity(
        key: '/modules/home/pages/home',
        uri: Uri.parse('/modules/home/pages/home'),
        routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
          ctx,
          settings,
          const a0.HomePage(),
        ),
      ),
      RouteEntity(
        key: '/modules/udp/ui/pages/udp',
        uri: Uri.parse('/modules/udp/ui/pages/udp'),
        routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
          ctx,
          settings,
          const a1.UdpPage(),
        ),
      ),
      RouteEntity(
        key: '/modules/configs/pages/device_configuration',
        uri: Uri.parse('/modules/configs/pages/device_configuration'),
        routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
          ctx,
          settings,
          const a2.DeviceConfigurationPage(),
        ),
      ),
      RouteEntity(
        key: '/modules/configs/pages/configs',
        uri: Uri.parse('/modules/configs/pages/configs'),
        routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
          ctx,
          settings,
          const a3.ConfigsPage(),
        ),
      ),
      RouteEntity(
        key: '/modules/startup/pages/startup',
        uri: Uri.parse('/modules/startup/pages/startup'),
        routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
          ctx,
          settings,
          const a4.StartupPage(),
        ),
      ),
      RouteEntity(
        key: '/modules/scanner/pages/scanner',
        uri: Uri.parse('/modules/scanner/pages/scanner'),
        routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
          ctx,
          settings,
          const a5.ScannerPage(),
        ),
      ),
    ];

const routePaths = (
  path: '/',
  modules: (
    path: '/modules',
    home: (
      path: '/modules/home',
      pages: (
        path: '/modules/home/pages',
        home: '/modules/home/pages/home',
      ),
    ),
    udp: (
      path: '/modules/udp',
      ui: (
        path: '/modules/udp/ui',
        pages: (
          path: '/modules/udp/ui/pages',
          udp: '/modules/udp/ui/pages/udp',
        ),
      ),
    ),
    configs: (
      path: '/modules/configs',
      pages: (
        path: '/modules/configs/pages',
        deviceConfiguration: '/modules/configs/pages/device_configuration',
        configs: '/modules/configs/pages/configs',
      ),
    ),
    startup: (
      path: '/modules/startup',
      pages: (
        path: '/modules/startup/pages',
        startup: '/modules/startup/pages/startup',
      ),
    ),
    scanner: (
      path: '/modules/scanner',
      pages: (
        path: '/modules/scanner/pages',
        scanner: '/modules/scanner/pages/scanner',
      ),
    ),
  ),
);
