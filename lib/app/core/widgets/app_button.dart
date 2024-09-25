import 'package:flutter/material.dart';

import '../extensions/build_context_extensions.dart';
import '../extensions/number_extensions.dart';

enum ButtonType {
  primary,
  secondary,
  text,
}

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    this.type = ButtonType.primary,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
  });

  final ButtonType type;
  final String text;
  final Function()? onPressed;
  final Function()? onLongPress;
  final Widget? leading;
  final Widget? trailing;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  final _defaultDuration = Durations.short4;

  WidgetStateProperty<Color> get _buttonColor {
    return WidgetStateProperty.resolveWith(
      (states) {
        Color baseColor = switch (widget.type) {
          ButtonType.primary => context.colorScheme.inversePrimary,
          ButtonType.secondary => Colors.transparent,
          ButtonType.text => Colors.transparent,
        };

        if (states.contains(WidgetState.disabled)) {
          baseColor = switch (widget.type) {
            ButtonType.text => baseColor,
            _ => context.theme.disabledColor,
          };
        } else if (states.contains(WidgetState.pressed)) {
          baseColor = baseColor;
        }

        return baseColor;
      },
    );
  }

  WidgetStateProperty<Color> get _overlayColor {
    return WidgetStateProperty.resolveWith(
      (states) {
        Color baseColor = switch (widget.type) {
          ButtonType.text => Colors.transparent,
          ButtonType.primary || ButtonType.secondary => context.colorScheme.primary.withOpacity(.05),
        };

        if (states.contains(WidgetState.pressed)) {
          baseColor = switch (widget.type) {
            ButtonType.primary => Color.alphaBlend(context.colorScheme.primary.withOpacity(.2), baseColor),
            ButtonType.secondary => baseColor.withOpacity(.1),
            ButtonType.text => baseColor,
          };
        }

        return baseColor;
      },
    );
  }

  WidgetStateProperty<BorderSide> get _borderColor {
    return WidgetStateProperty.resolveWith(
      (states) {
        Color baseColor = switch (widget.type) {
          ButtonType.primary => context.colorScheme.inversePrimary,
          ButtonType.text => Colors.transparent,
          ButtonType.secondary => context.colorScheme.primary,
        };

        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(color: Colors.transparent, width: 0);
        }

        return BorderSide(color: baseColor, width: 1);
      },
    );
  }

  WidgetStateProperty<Size> get _size {
    return WidgetStateProperty.all(
      switch (widget.type) {
        ButtonType.text => const Size(0, 42),
        _ => const Size.fromHeight(48),
      },
    );
  }

  WidgetStateProperty<TextStyle> get _textStyle {
    return WidgetStateProperty.all(
      switch (widget.type) {
        ButtonType.primary || ButtonType.secondary => context.textTheme.titleMedium!,
        ButtonType.text => context.textTheme.titleSmall!,
      },
    );
  }

  WidgetStateProperty<Color> get _textColor {
    return WidgetStateProperty.resolveWith(
      (states) {
        Color baseColor = switch (widget.type) {
          ButtonType.primary || ButtonType.secondary => context.colorScheme.onSurface,
          ButtonType.text => context.colorScheme.primary,
        };

        if (states.contains(WidgetState.disabled)) {
          baseColor = switch (widget.type) {
            ButtonType.text => baseColor,
            _ => Colors.white.withOpacity(.7),
          };
        }

        return baseColor;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        alignment: Alignment.center,
        side: _borderColor,
        minimumSize: _size,
        foregroundColor: _textColor,
        backgroundColor: _buttonColor,
        overlayColor: _overlayColor,
        textStyle: _textStyle,
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
      ),
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: _defaultDuration,
            child: Visibility(
              visible: widget.leading != null,
              child: widget.leading ?? const SizedBox.shrink(),
            ),
          ),
          Visibility(
            visible: widget.leading != null,
            child: 8.0.asSpace,
          ),
          Flexible(
            child: AnimatedSwitcher(
              duration: _defaultDuration,
              child: FittedBox(
                child: Text(
                  key: ValueKey(widget.text),
                  widget.text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.trailing != null,
            child: 8.0.asSpace,
          ),
          Visibility(
            visible: widget.trailing != null,
            child: widget.trailing ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
