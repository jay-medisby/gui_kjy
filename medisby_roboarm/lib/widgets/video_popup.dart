import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../theme/colors.dart';

/// 동영상 팝업을 표시하는 헬퍼 함수
void showVideoPopup(BuildContext context, String assetPath) {
  showDialog(
    context: context,
    barrierColor: AppColors.modalOverlay,
    builder: (_) => _VideoPopupDialog(assetPath: assetPath),
  );
}

class _VideoPopupDialog extends StatefulWidget {
  final String assetPath;

  const _VideoPopupDialog({required this.assetPath});

  @override
  State<_VideoPopupDialog> createState() => _VideoPopupDialogState();
}

class _VideoPopupDialogState extends State<_VideoPopupDialog> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset(widget.assetPath);
    try {
      await _videoController.initialize();
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          allowFullScreen: false,
          showOptions: false,
          hideControlsTimer: const Duration(seconds: 1),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 720,
              height: 540,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // 동영상 영역
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildContent(),
                  ),
                  // 닫기 버튼
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return const Center(
        child: Text(
          '동영상을 재생할 수 없습니다',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    if (_chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Chewie(controller: _chewieController!);
  }
}
