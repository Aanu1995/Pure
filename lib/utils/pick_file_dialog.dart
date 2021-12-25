import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'palette.dart';

// options available for user in bottom when trying to upload either image or file
enum FileOption { gallery, camera, document, delete }

void onItemSelected(BuildContext context, FileOption option) {
  Navigator.pop(context, option);
}

Future<FileOption?> showFileUploadBottomSheet(BuildContext context,
    {bool imagesOnly = false, bool showDeleteOption = false}) async {
  if (Platform.isAndroid) {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            children: <Widget>[
              _Item2(
                title: "Camera",
                icon: Icons.photo_camera,
                onTap: () => onItemSelected(context, FileOption.camera),
              ),
              _Item2(
                title: "Gallery",
                icon: Icons.image,
                onTap: () => onItemSelected(context, FileOption.gallery),
              ),
              if (!imagesOnly)
                _Item2(
                  title: "Document",
                  icon: Icons.description,
                  onTap: () => onItemSelected(context, FileOption.document),
                ),
              if (showDeleteOption)
                _Item2(
                  title: "Delete",
                  icon: Icons.delete_outlined,
                  onTap: () => onItemSelected(context, FileOption.delete),
                ),
            ],
          ),
        );
      },
    );
  } else if (Platform.isIOS) {
    return await showCupertinoModalPopup<FileOption>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => onItemSelected(context, FileOption.camera),
              child: _Item(title: "Camera", icon: Icons.photo_camera),
            ),
            CupertinoActionSheetAction(
              onPressed: () => onItemSelected(context, FileOption.gallery),
              child: _Item(title: "Photo Library", icon: Icons.image),
            ),
            if (!imagesOnly)
              CupertinoActionSheetAction(
                onPressed: () => onItemSelected(context, FileOption.document),
                child: _Item(title: "Document", icon: Icons.description),
              ),
            if (showDeleteOption)
              CupertinoActionSheetAction(
                onPressed: () => onItemSelected(context, FileOption.delete),
                child: _Item(title: "Delete", icon: Icons.delete_outlined),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primaryVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Item({Key? key, required this.title, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Palette.tintColor, size: 28.0),
          const SizedBox(width: 16.0),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primaryVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Item2 extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;
  const _Item2({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 28.0, color: Palette.tintColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primaryVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}
