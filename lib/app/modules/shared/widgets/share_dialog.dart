import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({
    super.key,
    required this.projectAddress,
  });

  final String projectAddress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Card(
          color: context.colorScheme.inversePrimary,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QrImageView(
                    data: projectAddress,
                    size: 300,
                    padding: const EdgeInsets.all(12),
                    backgroundColor: context.colorScheme.primary,
                    embeddedImage: const AssetImage("assets/logo.png"),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: const Size(101, 56),
                      color: context.colorScheme.inversePrimary,
                    ),
                    eyeStyle: QrEyeStyle(
                      color: context.colorScheme.surface,
                      eyeShape: QrEyeShape.circle,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      color: context.colorScheme.surface,
                      dataModuleShape: QrDataModuleShape.circle,
                    ),
                  ),
                ),
                24.asSpace,
                SelectableText(
                  projectAddress,
                  style: context.textTheme.titleMedium,
                ),
                18.asSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () async {
                        Navigator.pop(context);

                        await Clipboard.setData(
                          ClipboardData(text: projectAddress),
                        );

                        toastification.show(
                          type: ToastificationType.success,
                          style: ToastificationStyle.minimal,
                          autoCloseDuration: const Duration(seconds: 2),
                          title: const Text("Código copiado"),
                          closeOnClick: true,
                        );
                      },
                    ),
                    24.asSpace,
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      onPressed: () {
                        Share.share(projectAddress);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
