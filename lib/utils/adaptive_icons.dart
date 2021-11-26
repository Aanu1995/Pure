import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveIcons {
  const AdaptiveIcons();

  // share icon
  static IconData get share =>
      Platform.isIOS ? CupertinoIcons.share : Icons.share_outlined;

  // delete icon
  static IconData get delete =>
      Platform.isIOS ? CupertinoIcons.delete : Icons.delete_forever_outlined;

  // edit icon
  static IconData get edit => Icons.edit;

  // settings icon
  static IconData get settings => Icons.settings_outlined;
}
