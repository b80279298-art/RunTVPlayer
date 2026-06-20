import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../managers/player_manager.dart';
import '../managers/settings_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';

class PlayerWidget extends StatefulWidget {
  final String slotId;
  final bool isMain;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool showOverlay;
  final bool isSwapping;

  const PlayerWidget({
    super.key,
    required this.slotId,
    this.isMain = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.showOverlay = false,
    this.isSwapping = false,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget>
    with SingleTickerProviderStateMixin {
  VideoController? _controller;
  late AnimationController _swapAnim;
  late Animation<double> _swapScale;

  @override
  void initState() {
    super.initState();
    _swapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _swapScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _swapAnim, curve: Curves.easeInOut),
    );
    _initController();
  }

  Future<void> _initController() async {
    final pm = context.read<PlayerManager>();
    final player = pm.getPlayer(widget.slotId);
    if (player != null) {
      final ctrl = VideoController(player);
      if (mounted) setState(() => _controller = ctrl);
    }
  }

  @override
  void didUpdateWidget(PlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSwapping && !oldWidget.isSwapping) {
      _swapAnim.forward().then((_) => _swapAnim.reverse());
    }
    if (oldWidget.slotId != widget.slotId) {
      _initController();
    }
  }

  @override
  void dispose() {
    _swapAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerManager>(
      builder: (context, pm, _) {
        final state = pm.getState(widget.slotId);
        final stream = pm.getStream(widget.slotId);

        return ScaleTransition(
          scale: _swapScale,
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onLongPress: widget.onLongPress,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isMain ? 0 : 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: !widget.isMain
                      ? Border.all(
                          color: AppColors.pipBorder,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_controller != null)
                      Video(
                        controller: _controller!,
                        controls: NoVideoControls,
                        fit: BoxFit.contain,
                      )
                    else
                      _EmptyPlayer(stream: stream),

                    if (state?.isBuffering == true && stream != null)
                      const _BufferingOverlay(),

                    if (state?.hasError == true)
                      _ErrorOverlay(message: state?.errorMessage),

                    if (stream == null) _EmptyPlayer(stream: null),

                    if (widget.showOverlay || !widget.isMain)
                      _SlotOverlay(
                        isMain: widget.isMain,
                        stream: stream,
                        slotId: widget.slotId,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyPlayer extends StatelessWidget {
  final StreamModel? stream;
  const _EmptyPlayer({this.stream});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            color: AppColors.purple.withOpacity(0.4),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            stream != null ? stream!.name : 'Sem transmissão',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BufferingOverlay extends StatelessWidget {
  const _BufferingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: AppColors.purple,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  final String? message;
  const _ErrorOverlay({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 32),
          const SizedBox(height: 6),
          const Text(
            'Erro na transmissão',
            style: TextStyle(color: AppColors.error, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            'Reconectando...',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotOverlay extends StatelessWidget {
  final bool isMain;
  final StreamModel? stream;
  final String slotId;

  const _SlotOverlay({
    required this.isMain,
    required this.stream,
    required this.slotId,
  });

  @override
  Widget build(BuildContext context) {
    if (stream == null) return const SizedBox.shrink();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Text(
          stream!.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMain ? 13 : 9,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
