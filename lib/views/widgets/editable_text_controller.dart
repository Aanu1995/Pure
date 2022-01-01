import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../model/pure_user_model.dart';

class EditableTextController extends TextEditingController {
  EditableTextController({String? text}) : super(text: text);

  final Map<RegExp, TextStyle> patternMatchMap = {
    RegExp(r"\B@[a-zA-Z0-9]+\b"): TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.blue,
    ),
  };

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<TextSpan> children = [];
    List<String> usernames = [];

    final state = BlocProvider.of<GroupCubit>(context).state;
    if (state is GroupMembers) {
      final members = state.members.toList();
      members.removeWhere((element) => element.id == CurrentUser.currentUserId);
      usernames = members.map((e) => e.username).toList();
    }

    // Validating with REGEX

    text.splitMapJoin(
      patternMatchMap.keys.first,
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return span.toString();
      },
      onMatch: (Match m) {
        if (usernames.contains(m[0]!.split("@").last)) {
          children.add(
            TextSpan(text: m[0], style: patternMatchMap.values.first),
          );
        } else {
          children.add(TextSpan(text: m[0], style: style));
        }

        return "";
      },
    );
    return TextSpan(style: style, children: children);
  }
}
