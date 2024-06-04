import 'package:routefly/routefly.dart';

import 'app/modules/devices/ui/pages/udp_page.dart' as a1;
import 'app/modules/(udp)/ui/pages/udp_page.dart' as a0;

List<RouteEntity> get routes => [
  RouteEntity(
    key: '/modules/udp/ui/pages/udp',
    uri: Uri.parse('/modules/udp/ui/pages/udp'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a0.UdpPage(),
    ),
  ),
  RouteEntity(
    key: '/modules/devices/ui/pages/udp',
    uri: Uri.parse('/modules/devices/ui/pages/udp'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a1.UdpPage(),
    ),
  ),
];

const routePaths = (
  path: '/',
  modules: (
    path: '/modules',
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
    devices: (
      path: '/modules/devices',
      ui: (
        path: '/modules/devices/ui',
        pages: (
          path: '/modules/devices/ui/pages',
          udp: '/modules/devices/ui/pages/udp',
        ),
      ),
    ),
  ),
);
