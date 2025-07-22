import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';

class CustomInputField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? Function(String?) validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final bool isDropdown;
  final List<String>? items;
  final String? selectedValue;
  final void Function(String?)? onChanged;
  final bool suffixIcon;
  final bool? isDense;
  final bool? readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final VoidCallback? onTap;


  const CustomInputField({
    Key? key,
    this.labelText,
    this.hintText,
    required this.validator,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines,
    this.isDropdown = false,
    this.items,
    this.selectedValue,
    this.onChanged,
    this.suffixIcon = false,
    this.isDense,
    this.readOnly,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.sentences,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(widget.labelText != null)
          Text(widget.labelText!, style: FontHelper.bold(fontSize: 18)),
          const SizedBox(height: 4),
          widget.isDropdown
              ? DropdownButtonFormField<String>(
            value: (widget.items?.contains(widget.selectedValue) ?? false)
                ? widget.selectedValue
                : null,
            isDense: true,
            items: widget.items
                ?.map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: FontHelper.regular(fontSize: 16)),
            ))
                .toList() ??
                [],
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              isDense: widget.isDense ?? false,
              hintText: widget.hintText,
              hintStyle: FontHelper.regular(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            validator: widget.validator,
          )
              : TextFormField(
            controller: widget.controller,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            readOnly: widget.readOnly ?? false,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText ? _obscureText : false,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines ?? 1,
            textCapitalization: widget.textCapitalization,
            style: FontHelper.regular(fontSize: 16),
            decoration: InputDecoration(
              isDense: widget.isDense ?? false,
              hintText: widget.hintText,
              hintStyle: FontHelper.regular(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              suffixIcon: widget.suffixIcon && widget.obscureText
                  ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : null,
              suffixIconConstraints:
              widget.isDense != null ? const BoxConstraints(maxHeight: 33) : null,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
          ),
        ],
      ),
    );
  }
}
