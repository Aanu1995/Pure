import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewFullPhoto extends StatelessWidget {
  final String imageURL;
  final String? tag;
  const ViewFullPhoto({Key? key, required this.imageURL, this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            backgroundDecoration: BoxDecoration(color: Colors.grey.shade50),
            heroAttributes:
                tag != null ? PhotoViewHeroAttributes(tag: tag!) : null,
            filterQuality: FilterQuality.high,
            imageProvider: CachedNetworkImageProvider(imageURL),
          ),
          Positioned(
            top: 50.0,
            left: 16.0,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(500),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: 22.0,
                child: const Icon(
                  Icons.close_outlined,
                  color: Colors.black,
                  size: 28.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewProfilePhoto extends StatelessWidget {
  final String imageURL;
  const ViewProfilePhoto({Key? key, required this.imageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 1.0.sw * 0.49,
                foregroundImage: CachedNetworkImageProvider(imageURL),
              ),
            ),
          ),
          Positioned(
            top: 50.0,
            left: 16.0,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(500),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: 22.0,
                child: const Icon(
                  Icons.close_outlined,
                  color: Colors.black,
                  size: 28.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
