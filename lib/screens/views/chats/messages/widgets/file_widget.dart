import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../model/chat/attachment_model.dart';
import '../../../../../utils/app_theme.dart';
import '../../../../../utils/navigate.dart';
import '../../../photo_view_screen.dart';

class ImageView extends StatelessWidget {
  final List<Attachment> attachments;
  const ImageView({Key? key, required this.attachments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        return _SingleImage(newAttachment: newAttachment);
    } else {
      final height = 1.sw * 0.18 * (attachments.length <= 2 ? 2 : 4);
      return SizedBox(
        width: 1.sw * 0.72,
        height: height,
        child: InkWell(
          onTap: () => pushToViewAllImages(context),
          child: GridView.builder(
            itemCount: attachments.length <= 4 ? attachments.length : 4,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final newAttachment = attachments[index] as ImageAttachment;
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: newAttachment.localFile != null
                        ? Image.file(newAttachment.localFile!,
                            fit: BoxFit.cover)
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
                  ),
                  if (index == 3 && attachments.length > 4)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text(
                        "+${attachments.length - 4}",
                        style: const TextStyle(
                          fontSize: 40.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ),
      );
    }
  }

  void pushToViewAllImages(BuildContext context) {
    if (attachments.first.localFile == null) {
      push(context: context, page: ViewAllImages(attachments: attachments));
    }
  }
}

class _SingleImage extends StatelessWidget {
  final ImageAttachment newAttachment;
  final BorderRadius? borderRadius;
  const _SingleImage({Key? key, required this.newAttachment, this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: newAttachment.fileURL!,
      child: InkWell(
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(4.0),
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
  }
}

class ViewAllImages extends StatelessWidget {
  final List<Attachment> attachments;
  const ViewAllImages({Key? key, required this.attachments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${attachments.length} Photos",
          style: const TextStyle(
            fontFamily: Palette.sanFontFamily,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: attachments.length,
        padding: EdgeInsets.all(0.0),
        itemBuilder: (context, index) {
          final attachment = attachments[index] as ImageAttachment;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _SingleImage(
              newAttachment: attachment,
              borderRadius: BorderRadius.zero,
            ),
          );
        },
      ),
    );
  }
}
