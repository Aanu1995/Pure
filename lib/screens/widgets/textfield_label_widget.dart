import 'package:flutter/material.dart';

class TextFieldLabelWidget extends StatelessWidget {
  const TextFieldLabelWidget(
      {Key? key, required this.label, this.required = true})
      : super(key: key);

  final String label;
  final bool required;

  static final _style = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.20,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: label, style: _style),
          if (required)
            TextSpan(
              text: ' *',
              style: _style.copyWith(fontSize: 16.0, color: Colors.red),
            ),
        ],
      ),
    );
  }
}

class TextFieldLabelDescWidget extends StatelessWidget {
  const TextFieldLabelDescWidget(
      {Key? key, required this.label, this.required = true, required this.desc})
      : super(key: key);

  final String label;
  final String desc;
  final bool required;

  static final _style = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.20,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: label, style: _style),
              if (required)
                TextSpan(
                  text: ' *',
                  style: _style.copyWith(fontSize: 16.0, color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          desc,
          style: _style.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 13.0,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        )
      ],
    );
  }
}
