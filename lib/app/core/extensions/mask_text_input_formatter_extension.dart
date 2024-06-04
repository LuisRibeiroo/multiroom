import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

extension MaskTextInputFormatterExt on MaskTextInputFormatter {
  static MaskTextInputFormatter phone() => MaskTextInputFormatter(
        mask: "(##) #####-####",
        filter: {"#": RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter monetary() => MaskTextInputFormatter(
        mask: "###,##",
        filter: {"#": RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter ip() => MaskTextInputFormatter(
        mask: "###.###.###.###",
        filter: {"#": RegExp(r'[0-9]')},
      );
}
