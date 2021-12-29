import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pure/utils/app_utils.dart';

import '../../../../../utils/palette.dart';

class PureLinkPreview extends StatelessWidget {
  final PreviewData? linkPreviedData;
  const PureLinkPreview({Key? key, required this.linkPreviedData})
      : super(key: key);

  static final imageSize = (1.sw * 0.72) * 0.22;
  final _style = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    fontFamily: Palette.sanFontFamily,
  );

  bool _hasData(PreviewData? previewData) {
    return previewData?.title != null || previewData?.description != null;
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    if (!_hasData(linkPreviedData)) return Offstage();
    return InkWell(
      onTap: () => launchIfCan(context, linkPreviedData!.link!),
      child: Container(
        width: 1.sw * 0.72,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Wrap(
          children: [
            if (linkPreviedData?.image != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                ),
                child: CachedNetworkImage(
                  imageUrl: linkPreviedData!.image!.url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Offstage(),
                  width: imageSize,
                  height: imageSize,
                ),
              ),
            Wrap(
              children: [
                if (linkPreviedData!.title != null)
                  Text(
                    linkPreviedData!.title!,
                    style: _style.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                if (linkPreviedData!.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      linkPreviedData!.description!,
                      style: _style.copyWith(
                        color: color.withOpacity(0.5),
                        fontSize: 12.0,
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
