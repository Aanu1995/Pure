import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/palette.dart';
import '../../../../../utils/file_utils.dart';

class FilePickedWidget extends StatelessWidget {
  final PlatformFile file;
  final void Function()? onCancelTap;
  final void Function()? onSendPressed;
  const FilePickedWidget({
    Key? key,
    required this.file,
    required this.onCancelTap,
    this.onSendPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onCancelTap,
          borderRadius: BorderRadius.circular(500),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            child: CircleAvatar(
              radius: 20.0,
              child: CircleAvatar(
                radius: 19.0,
                backgroundColor: Theme.of(context).dialogBackgroundColor,
                child: const Icon(Icons.cancel, size: 35),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                width: 2.0,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  size: 30.0,
                  color: Theme.of(context).colorScheme.secondaryVariant,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "${file.getFileSize} . ${file.extension}",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: onSendPressed,
          borderRadius: BorderRadius.circular(500),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            child: CircleAvatar(
              radius: 19.0,
              backgroundColor: Palette.tintColor,
              child: Icon(
                Icons.send,
                size: 22.0,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
