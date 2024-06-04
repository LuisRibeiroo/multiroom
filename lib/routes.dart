import 'package:routefly/routefly.dart';

import 'app/(modules)/devices/ui/pages/home_page.dart' as a1;
import 'app/(modules)/udp/ui/pages/udp_page.dart' as a0;

List<RouteEntity> get routes => [
  RouteEntity(
    key: '/udp/ui/pages/udp',
    uri: Uri.parse('/udp/ui/pages/udp'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a0.UdpPage(),
    ),
  ),
  RouteEntity(
    key: '/devices/ui/pages/home',
    uri: Uri.parse('/devices/ui/pages/home'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a1.HomePage(),
    ),
  ),
];

const routePaths = (
  path: '/',
  udp: (
    path: '/udp',
    ui: (
      path: '/udp/ui',
      pages: (
        path: '/udp/ui/pages',
        udp: '/udp/ui/pages/udp',
      ),
    ),
  ),
  devices: (
    path: '/devices',
    ui: (
      path: '/devices/ui',
      pages: (
        path: '/devices/ui/pages',
        home: '/devices/ui/pages/home',
      ),
    ),
  ),
);
