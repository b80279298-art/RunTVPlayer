import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/layout_manager.dart';
import '../managers/player_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';
import 'player_widget.dart';

class PipWidget extends StatefulWidget {
  final int slotIndex;
  final SlotConfig config;
  final Size screenSize;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool isSwapping;

  const PipWidget({
    super.key,
    required this.slotIndex,
    required this.config,
    required this.screenSize,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.isSwapping = false,
  });

  @override
  State<PipWidget> createState() => _PipWidgetState();
}

class _PipWidgetState extends State<PipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  double _currentScale = 1.0;
  double _startScale = 1.0;

  @override
  void initState() {
    super.initState();
    _entryAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entryAnim, curve: Curves.elasticOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryAnim, curve: const Interval(0.0, 0.5)),
    );
    _entryAnim.forward();
  }

  @override
  void dispose() {
    _entryAnim.dispose();
    super.dispose();
  }

  Offset _positionForConfig(SlotConfig config, Size pipSize) {
    const margin = 12.0;
    switch (config.pipPosition ?? PipPosition.bottomRight) {
      case PipPosition.topLeft:
        return const Offset(margin, margin);
      case PipPosition.topRight:
        return Offset(widget.screenSize.width - pipSize.width - margin, margin);
      case PipPosition.bottomLeft:
        return Offset(margin, widget.screenSize.height - pipSize.height - margin - 56);
      case PipPosition.bottomRight:
        return Offset(
          widget.screenSize.width - pipSize.width - margin,
          widget.screenSize.height - pipSize.height - margin - 56,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = context.watch<LayoutManager>();
    final fraction = widget.config.pipFraction.clamp(0.15, 0.45);
    final pipW = widget.screenSize.width * fraction * _currentScale;
    final pipH = pipW * (9 / 16);
    final pipSize = Size(pipW, pipH);
    final offset = _positionForConfig(widget.config, pipSize);

    return FadeTransition(
      opacity: _opacityAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Positioned(
          left: offset.dx,
          top: offset.dy,
          child: GestureDetector(
            onScaleStart: (details) {
              _startScale = _currentScale;
            },
            onScaleUpdate: (details) {
              if (details.pointerCount == 2) {
                final newScale = (_startScale * details.scale).clamp(0.5, 1.5);
                setState(() => _currentScale = newScale);
                final newFraction = (fraction * details.scale).clamp(0.15, 0.45);
                lm.setPipFraction(widget.slotIndex, newFraction);
              }
            },
            child: PlayerWidget(
              slotId: widget.config.slotId,
              isMain: false,
              onTap: widget.onTap,
              onDoubleTap: widget.onDoubleTap,
              onLongPress: widget.onLongPress,
              isSwapping: widget.isSwapping,
            ),
          ),
        ),
      ),
    );
  }
}

class PipPositionMenu extends StatelessWidget {
  final int slotIndex;
  final VoidCallback onClose;

  const PipPositionMenu({
    super.key,
    required this.slotIndex,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final lm = context.read<LayoutManager>();
    final positions = [
      (PipPosition.topLeft, 'Sup. Esquerdo', Icons.north_west),
      (PipPosition.topRight, 'Sup. Direito', Icons.north_east),
      (PipPosition.bottomLeft, 'Inf. Esquerdo', Icons.south_west),
      (PipPosition.bottomRight, 'Inf. Direito', Icons.south_east),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posição da mini-tela',
            style: TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: positions.map((p) {
              final (pos, label, icon) = p;
              final isSelected = lm.slots[slotIndex].pipPosition == pos;
              return InkWell(
                onTap: () {
                  lm.setPipPosition(slotIndex, pos);
                  onClose();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.purpleDark : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.purple : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.onSurface),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.onSurface,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
