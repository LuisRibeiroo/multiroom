import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';

class NoDevicesWidget extends StatelessWidget {
  const NoDevicesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(
            Icons.device_unknown_rounded,
            size: 80,
          ),
          12.asSpace,
          Text(
            'Voce ainda não possui dispositivos',
            style: context.textTheme.titleLarge,
          ),
          const Spacer(),
          40.asSpace,
        ],
      ),
    );
  }
}
