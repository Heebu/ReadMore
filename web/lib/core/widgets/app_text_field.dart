import 'package:flartdart/flartdart.dart';
import '../utils/web_dom_helper.dart';

/// Reliable DOM-preserving text input for FlartDart.
///
/// Unlike [FDTextField], this widget sets both `id` and `key` on the underlying
/// `<input>` / `<textarea>` VDOM node and avoids rebuilding on every keystroke,
/// preventing focus loss and dropped characters across all browsers.
class AppTextField extends StatefulWidget {
  final String? value;
  final String? initialValue;
  final String? placeholder;
  final String? ariaLabel;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final TextStyle? style;
  final EdgeInsets? padding;
  final FlartColor? backgroundColor;
  final FlartColor? borderColor;
  final double? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppTextField({
    this.value,
    this.initialValue,
    this.placeholder,
    this.ariaLabel,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.style,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    super.key,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  static int _idCounter = 0;
  late final String _inputId;
  late String _value;

  @override
  void initState() {
    super.initState();
    _idCounter++;
    _inputId = 'app_input_${_idCounter}_${DateTime.now().microsecondsSinceEpoch}';
    _value = widget.value ?? widget.initialValue ?? '';
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _value) {
      _value = widget.value!;
      setInputValueById(_inputId, _value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isMultiline = widget.maxLines != null && widget.maxLines! > 1;
    final effectiveFillColor = widget.backgroundColor ?? theme.cardColor;
    final effectiveBorderColor = widget.borderColor ?? theme.dividerColor;
    final effectiveRadius = BorderRadius.circular(widget.borderRadius ?? 4.0);
    final effectivePadding = widget.padding ??
        EdgeInsets.only(
          left: widget.prefixIcon != null ? 40 : 12,
          right: widget.suffixIcon != null ? 40 : 12,
          top: 10,
          bottom: 10,
        );

    final type = widget.obscureText
        ? 'password'
        : _keyboardTypeToString(widget.keyboardType);

    final inputStyles = <String, String>{
      'box-sizing': 'border-box',
      'padding': effectivePadding.toCss(),
      'font-size': widget.style?.fontSize != null
          ? '${widget.style!.fontSize}px'
          : '14px',
      'color':
          widget.style?.color?.toString() ?? theme.textStyle.color.toString(),
      'border': 'none',
      'outline': 'none',
      'width': '100%',
      'background': 'transparent',
      'font-family': widget.style?.fontFamily ?? 'inherit',
      'resize': isMultiline ? 'vertical' : 'none',
    };

    final attributes = <String, String>{
      if (widget.placeholder != null) 'placeholder': widget.placeholder!,
      if (widget.ariaLabel != null) 'aria-label': widget.ariaLabel!,
      if (widget.placeholder != null && widget.ariaLabel == null)
        'aria-label': widget.placeholder!,
      if (widget.maxLength != null) 'maxlength': widget.maxLength!.toString(),
      if (widget.readOnly) 'readonly': '',
      if (widget.autofocus) 'autofocus': '',
      if (!isMultiline) 'type': type,
      if (!isMultiline) 'value': _value,
      if (isMultiline && widget.maxLines != null)
        'rows': widget.maxLines!.toString(),
    };

    final inputElement = FDElement(
      tag: isMultiline ? 'textarea' : 'input',
      id: _inputId,
      key: ValueKey(_inputId),
      attributes: attributes,
      styles: inputStyles,
      textContent: isMultiline ? _value : null,
      events: {
        'input': (dynamic e) {
          final nextVal = extractInputValue(e, elementId: _inputId);
          if (nextVal != null) {
            _value = nextVal;
            widget.onChanged?.call(nextVal);
          }
        },
        if (!isMultiline)
          'keydown': (dynamic e) {
            final key = extractKeyboardEventKey(e);
            if (key == 'Enter') {
              final nextVal = extractInputValue(e, elementId: _inputId) ?? _value;
              _value = nextVal;
              widget.onSubmitted?.call(nextVal);
            }
          },
      },
    );

    return FDContainer(
      width: double.infinity,
      decoration: BoxDecoration(
        color: effectiveFillColor,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorderColor, width: 1),
      ),
      cssStyle: const {'width': '100%'},
      child: FDStack(
        cssStyle: const {'width': '100%'},
        children: [
          inputElement,
          if (widget.prefixIcon != null)
            FDPositioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: FDCenter(child: widget.prefixIcon!),
            ),
          if (widget.suffixIcon != null)
            FDPositioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: FDCenter(child: widget.suffixIcon!),
            ),
        ],
      ),
    );
  }

  String _keyboardTypeToString(TextInputType type) {
    switch (type) {
      case TextInputType.email:
        return 'email';
      case TextInputType.number:
      case TextInputType.phone:
        return 'number';
      case TextInputType.url:
        return 'url';
      default:
        return 'text';
    }
  }
}
