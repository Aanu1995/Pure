import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/palette.dart';

class PureLinkPreview extends StatelessWidget {
  final PreviewData? linkPreviedData;
  const PureLinkPreview({Key? key, required this.linkPreviedData})
      : super(key: key);

  final _style = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    fontFamily: Palette.sanFontFamily,
  );

  @override
  Widget build(BuildContext context) {
    if (linkPreviedData == null) return Offstage();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: LinkPreview(
        linkStyle: _style.copyWith(color: Colors.blueAccent),
        metadataTitleStyle: _style,
        textStyle: _style,
        metadataTextStyle: _style,
        padding: EdgeInsets.all(8.0),
        enableAnimation: true,
        imageBuilder: (imageURL) {
          return CachedNetworkImage(
            width: 1.sw * 0.72,
            imageUrl: imageURL,
            fit: BoxFit.fitWidth,
            placeholder: (_, __) => Offstage(),
          );
        },
        onPreviewDataFetched: (data) {},
        previewData: linkPreviedData!,
        text: linkPreviedData!.link ?? "",
        width: 1.sw,
      ),
    );
  }
}
