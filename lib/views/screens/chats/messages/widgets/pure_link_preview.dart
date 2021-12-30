import 'package:cached_network_image/cached_network_image.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../utils/app_utils.dart';
import '../../../../../utils/palette.dart';

class PureLinkPreview extends StatelessWidget {
  final PreviewData? linkPreviedData;
  const PureLinkPreview({Key? key, required this.linkPreviedData})
      : super(key: key);

  static final imageSize = (1.sw * 0.72) * 0.22;
  final _style = const TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    fontFamily: Palette.sanFontFamily,
  );

  bool _hasData(PreviewData? previewData) {
    return previewData?.title != null || previewData?.description != null;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    if (!_hasData(linkPreviedData)) return Offstage();
    return InkWell(
      onTap: () => launchIfCan(context, linkPreviedData!.link!),
      child: SizedBox(
        width: 1.sw * 0.72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: FloatColumn(
            children: [
              if (linkPreviedData?.image != null)
                Floatable(
                  float: FCFloat.start,
                  padding: const EdgeInsets.only(right: 2.0),
                  child: ClipRRect(
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
                ),
              if (linkPreviedData!.title != null)
                WrappableText(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  text: TextSpan(
                    text: linkPreviedData!.title!,
                    style: _style.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color.withOpacity(0.9),
                    ),
                  ),
                ),
              if (linkPreviedData!.title != null)
                WrappableText(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 3),
                  text: TextSpan(
                    text: linkPreviedData!.description!,
                    style: _style.copyWith(
                      color: color.withOpacity(0.7),
                      fontSize: 12.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
