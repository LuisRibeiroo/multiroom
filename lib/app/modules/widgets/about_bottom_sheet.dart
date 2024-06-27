import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/extensions/number_extensions.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/extensions/build_context_extensions.dart';

class AboutBottomSheet extends StatelessWidget {
  const AboutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                "assets/logo_completo.png",
                height: 48.0,
              ),
            ),
            // Text(
            //   "Multiroom",
            //   style: context.textTheme.titleLarge,
            // ),
          ],
        ),
        const Divider(height: 24, indent: 24, endIndent: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "CONTROLART DESENVOLVIMENTO DE EQUIPAMENTOS ELETRONICOS LTDA.",
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          "CNPJ: 28.436.336/0001-10",
          style: context.textTheme.bodyLarge,
        ),
        56.asSpace,
        ListTile(
          leading: const Icon(Icons.phone_rounded),
          trailing: const Icon(Icons.arrow_forward_rounded),
          title: const Text("(12) 4102-0025"),
          subtitle: const Text("Fixo"),
          onTap: () async {
            try {
              await launchUrl(Uri.parse("tel:+551241020025"));
            } catch (exception) {
              toastification.show(
                title: const Text("Erro ao tentar iniciar a ligação"),
                autoCloseDuration: const Duration(seconds: 5),
                style: ToastificationStyle.minimal,
                type: ToastificationType.error,
              );
            }
          },
        ),
        ListTile(
          leading: Icon(MdiIcons.whatsapp),
          trailing: const Icon(Icons.arrow_forward_rounded),
          title: const Text("(12) 98257-0319"),
          subtitle: const Text("WhatsApp"),
          onTap: () async {
            try {
              await launchUrl(Uri.parse("https://wa.me/+5512982570319"));
            } catch (exception) {
              toastification.show(
                title: const Text("Erro ao tentar iniciar o WhatsApp"),
                autoCloseDuration: const Duration(seconds: 5),
                style: ToastificationStyle.minimal,
                type: ToastificationType.error,
              );
            }
          },
        ),
      ],
    );
  }
}
