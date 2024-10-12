import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../shared/pages/options_menu.dart';

class AboutBottomSheet extends StatefulWidget {
  const AboutBottomSheet({super.key});

  @override
  State<AboutBottomSheet> createState() => _AboutBottomSheetState();
}

class _AboutBottomSheetState extends State<AboutBottomSheet> {
  String _appName = "";
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      final info = await PackageInfo.fromPlatform();

      setState(() {
        _appName = info.appName;
        _appVersion = "${info.version}+${info.buildNumber}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/logo_completo.png",
                height: 48.0,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () => Options.showTechBottomSheet(context),
                ),
              ),
            )
          ],
        ),
        Text(
          "$_appName v$_appVersion",
          style: context.textTheme.bodySmall,
        ),
        const Divider(height: 24, indent: 24, endIndent: 24),
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    "O ControlArt MRAudio é a solução ideal para gerenciar seu sistema de áudio multiroom de maneira simples e eficiente. Desenvolvido pela ControlArt, este aplicativo permite o controle de até 8 zonas de áudio estéreo ou até 16 zonas de áudio mono, oferecendo uma experiência sonora personalizada e de alta qualidade em toda a sua casa ou empresa.",
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  12.asSpace,
                  SelectableText(
                    "Funcionalidades para Instaladores:",
                    style: context.textTheme.labelLarge,
                    textAlign: TextAlign.start,
                  ),
                  SelectableText.rich(
                    textAlign: TextAlign.justify,
                    style: context.textTheme.bodySmall,
                    const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "• Configuração Segura: Acesse configurações avançadas protegidas por senha para configurar zonas em mono ou estéreo\n",
                        ),
                        TextSpan(
                          text:
                              "• Agrupamento de Zonas: Agrupe diferentes zonas de áudio para criar ambientes sonoros integrados\n",
                        ),
                        TextSpan(
                          text:
                              "• Ajuste de Volume Máximo: Defina limites de volume para cada zona, garantindo uma experiência sonora segura e controlada\n",
                        ),
                        TextSpan(
                          text: "• Ocultar Zonas: Oculte zonas específicas para simplificar o controle do sistema",
                        ),
                      ],
                    ),
                  ),
                  12.asSpace,
                  SelectableText(
                    "Funcionalidades para Usuários:",
                    style: context.textTheme.labelLarge,
                    textAlign: TextAlign.start,
                  ),
                  SelectableText.rich(
                    textAlign: TextAlign.justify,
                    style: context.textTheme.bodySmall,
                    const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "• Seleção de Inputs e Zonas: Escolha facilmente as entradas de áudio e as zonas que deseja controlar\n",
                        ),
                        TextSpan(
                          text:
                              "• Controle de Volume e Balanço: Ajuste o volume e o balanço de cada zona para obter a configuração sonora ideal\n",
                        ),
                        TextSpan(
                          text:
                              "• Equalizador de 6 Bandas: Utilize presets pré-definidos ou personalize o equalizador para adaptar o som ao seu gosto",
                        ),
                      ],
                    ),
                  ),
                  12.asSpace,
                  SelectableText(
                    "Benefícios:",
                    style: context.textTheme.labelLarge,
                    textAlign: TextAlign.start,
                  ),
                  SelectableText.rich(
                    textAlign: TextAlign.justify,
                    style: context.textTheme.bodySmall,
                    const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "• Facilidade de Uso: Interface intuitiva que permite controlar o sistema de áudio com apenas alguns toques\n",
                        ),
                        TextSpan(
                          text:
                              "• Flexibilidade: Ajuste cada detalhe dentro do seu ambiente para atender às suas necessidades específicas ou preferências musicais\n",
                        ),
                        TextSpan(
                          text:
                              "• Customização: Dê nomes às zonas e aos inputs para facilitar a navegação no aplicativo e crie uma experiência de áudio única e envolvente em cada espaço da sua casa ou empresa",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        20.asSpace,
        SelectableText(
          "Contato e Suporte",
          style: context.textTheme.titleMedium,
        ),
        ListTile(
          leading: const Icon(Icons.web_rounded),
          trailing: const Icon(Icons.arrow_forward_rounded),
          title: const Text("controlart.com.br"),
          subtitle: const Text("Site"),
          onTap: () async {
            try {
              await launchUrl(Uri.parse("https://controlart.com.br/contato/"));
            } catch (exception) {
              toastification.show(
                title: const Text("Erro ao tentar abrir o site"),
                autoCloseDuration: const Duration(seconds: 5),
                style: ToastificationStyle.minimal,
                type: ToastificationType.error,
                closeOnClick: true,
              );
            }
          },
        ),
        ListTile(
          leading: Icon(MdiIcons.instagram),
          trailing: const Icon(Icons.arrow_forward_rounded),
          title: const Text("@controlart_automacao"),
          subtitle: const Text("Instagram"),
          onTap: () async {
            try {
              await launchUrl(Uri.parse("https://instagram.com/controlart_automacao"));
            } catch (exception) {
              toastification.show(
                title: const Text("Erro ao tentar iniciar o WhatsApp"),
                autoCloseDuration: const Duration(seconds: 5),
                style: ToastificationStyle.minimal,
                type: ToastificationType.error,
                closeOnClick: true,
              );
            }
          },
        ),
      ],
    );
  }
}
