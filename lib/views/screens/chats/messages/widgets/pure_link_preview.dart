import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkify/linkify.dart';

import '../../../../../utils/palette.dart';

class PureLinkPreview extends StatefulWidget {
  final String text;
  const PureLinkPreview({Key? key, required this.text}) : super(key: key);

  @override
  _PureLinkPreviewState createState() => _PureLinkPreviewState();
}

class _PureLinkPreviewState extends State<PureLinkPreview> {
  late List<LinkifyElement> links;
  final _completer = Completer<PreviewData?>();

  final _style = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    fontFamily: Palette.sanFontFamily,
  );

  @override
  void initState() {
    super.initState();
    _initialize(widget.text);
  }

  Future<void> _initialize(String text) async {
    links = linkify(
      widget.text,
      options: LinkifyOptions(humanize: false),
      linkifiers: [UrlLinkifier()],
    ).where((element) {
      final link = element.text;
      if (link.contains("http") || link.contains("https")) return true;
      return false;
    }).toList();

    if (links.isNotEmpty) {
      print("Hello");
      final previewData = await getPreviewData(widget.text);
      _completer.complete(previewData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return links.isEmpty
        ? Offstage()
        : FutureBuilder<PreviewData?>(
            future: _completer.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
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
                    previewData: snapshot.data,
                    text: links[0].text,
                    width: 1.sw,
                  ),
                );
              return Offstage();
            },
          );
  }
}
