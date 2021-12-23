import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../../utils/app_theme.dart';

class TrimmerView extends StatefulWidget {
  final File file;
  const TrimmerView(this.file, {Key? key}) : super(key: key);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();
  final _isTrimmingNotifier = ValueNotifier(false);
  final _isPlayingNotifier = ValueNotifier(false);

  double _startValue = 0.0;
  double _endValue = 0.0;

  final _style = const TextStyle(
    fontSize: 17.0,
    fontFamily: Palette.sanFontFamily,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    await _trimmer.loadVideo(videoFile: widget.file);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _trimmer.videoPlayerController?.play();
    });
  }

  @override
  void dispose() {
    _isTrimmingNotifier.dispose();
    _isPlayingNotifier.dispose();
    _trimmer.videoPlayerController?.dispose();
    _trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF242424),
        appBar: AppBar(
          backgroundColor: const Color(0xFF242424),
          elevation: 0.0,
          leadingWidth: 100,
          centerTitle: true,
          leading: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: _style.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.05,
              ),
            ),
          ),
          title: Text("Edit video", style: _style),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: _isTrimmingNotifier,
              builder: (context, isTrimming, _) {
                return TextButton(
                  onPressed: isTrimming ? null : () => _trimVideo(),
                  child: Text(
                    "Trim",
                    style: _style.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.05,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Stack(
              fit: StackFit.expand,
              children: [
                // shows the video being trimmed
                VideoViewer(trimmer: _trimmer),
                InkWell(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isPlayingNotifier,
                    builder: (context, isPlaying, _) {
                      return Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Palette.tintColor,
                        size: 60.0,
                      );
                    },
                  ),
                  onTap: () => onButtonPressed(),
                ),
              ],
            ),
            // shows the trimmer container
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black54,
                width: 1.sw,
                height: 120,
                padding: EdgeInsets.fromLTRB(0, 4, 0, 20),
                child: Center(
                  child: TrimEditor(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: 1.sw * 0.96,
                    borderPaintColor: Palette.tintColor,
                    scrubberPaintColor: Palette.greenColor,
                    scrubberWidth: 2.0,
                    circleSize: 6,
                    maxVideoLength: const Duration(minutes: 2, seconds: 20),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        _isPlayingNotifier.value = value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _trimVideo() {
    _isTrimmingNotifier.value = true;

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        if (outputPath != null) Navigator.of(context).pop(File(outputPath));
        _isTrimmingNotifier.value = false;
      },
    );
  }

  Future<void> onButtonPressed() async {
    bool playbackState = await _trimmer.videPlaybackControl(
      startValue: _startValue,
      endValue: _endValue,
    );
    _isPlayingNotifier.value = playbackState;
  }
}
