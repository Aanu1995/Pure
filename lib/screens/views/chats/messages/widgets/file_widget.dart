import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../model/chat/attachment_model.dart';
import '../../../../../utils/navigate.dart';
import '../../../photo_view_screen.dart';

class FileWidget extends StatelessWidget {
  final List<Attachment> attachments;
  const FileWidget({Key? key, required this.attachments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (attachments.first is ImageAttachment) {
      if (attachments.length <= 1) {
        final newAttachment = attachments.first as ImageAttachment;
        if (newAttachment.localFile != null)
          return ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.file(
              newAttachment.localFile!,
              width: newAttachment.width.toDouble(),
            ),
          );
        else
          return Hero(
            tag: newAttachment.fileURL!,
            child: InkWell(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  imageUrl: newAttachment.fileURL!,
                  width: newAttachment.width.toDouble(),
                  placeholder: (context, _) {
                    return AspectRatio(
                      aspectRatio: newAttachment.width.toDouble() /
                          newAttachment.height.toDouble(),
                      child: Container(color: newAttachment.color),
                    );
                  },
                  errorWidget: (context, url, dynamic _) {
                    return AspectRatio(
                      aspectRatio: newAttachment.width.toDouble() /
                          newAttachment.height.toDouble(),
                      child: Container(color: newAttachment.color),
                    );
                  },
                ),
              ),
              onTap: () => push(
                context: context,
                page: ViewFullPhoto(
                  tag: newAttachment.fileURL!,
                  color: newAttachment.color,
                  imageURL: newAttachment.fileURL!,
                ),
              ),
            ),
          );
      } else {
        final height = 1.sw * 0.18 * (attachments.length <= 2 ? 2 : 4);
        return SizedBox(
          width: 1.sw * 0.72,
          height: height,
          child: GridView.builder(
            itemCount: attachments.length <= 4 ? attachments.length : 4,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              childAspectRatio: 0.96,
            ),
            itemBuilder: (context, index) {
              final newAttachment = attachments[index] as ImageAttachment;
              return ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: newAttachment.localFile != null
                    ? Image.file(
                        newAttachment.localFile!,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: newAttachment.fileURL!,
                        width: newAttachment.width.toDouble(),
                        fit: BoxFit.cover,
                        placeholder: (context, _) {
                          return Container(color: newAttachment.color);
                        },
                        errorWidget: (context, url, dynamic _) {
                          return Container(color: newAttachment.color);
                        },
                      ),
              );
            },
          ),
        );
      }
    }
    return Offstage();
  }
}
