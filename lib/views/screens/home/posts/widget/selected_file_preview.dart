import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../../utils/app_theme.dart';
import '../../../../widgets/page_transition.dart';
import '../video_trimmer_screen.dart';

class PostImagePreview extends StatelessWidget {
  final List<File> imageFiles;
  final Function(File) onImageRemoved;
  const PostImagePreview({
    Key? key,
    required this.imageFiles,
    required this.onImageRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 1.sw * 0.8,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: imageFiles.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        itemBuilder: (context, index) {
          final file = imageFiles[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: IconButton(
                    onPressed: () => onImageRemoved(file),
                    color: Theme.of(context).colorScheme.secondary,
                    icon: Icon(Icons.cancel),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostVideoPreview extends StatefulWidget {
  final File originalVideoFile;
  final File trimmedVideoFile;
  final Function() onVideoRemoved;
  final Function(File trimmedFile) onVideoTrimmed;
  const PostVideoPreview({
    Key? key,
    required this.originalVideoFile,
    required this.trimmedVideoFile,
    required this.onVideoRemoved,
    required this.onVideoTrimmed,
  }) : super(key: key);

  @override
  State<PostVideoPreview> createState() => _PostVideoPreviewState();
}

class _PostVideoPreviewState extends State<PostVideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.trimmedVideoFile);
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(_controller),
            InkWell(
              child: Center(
                child: Icon(
                  Icons.play_circle,
                  color: Palette.tintColor,
                  size: 60.0,
                ),
              ),
              onTap: () => trimVideo(context, widget.originalVideoFile),
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: IconButton(
                onPressed: () => widget.onVideoRemoved(),
                color: Theme.of(context).colorScheme.secondary,
                icon: Icon(Icons.cancel),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> trimVideo(BuildContext context, File file) async {
    final trimmedFile = await Navigator.of(context).push<File?>(
      PageTransition(
        child: TrimmerView(file),
        type: PageTransitionType.bottomToTop,
      ),
    );
    if (trimmedFile != null) widget.onVideoTrimmed(trimmedFile);
  }
}
