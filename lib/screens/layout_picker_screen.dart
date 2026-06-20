import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/layout_manager.dart';
import '../managers/player_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';

class LayoutPickerScreen extends StatelessWidget {
  const LayoutPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lm = context.watch<LayoutManager>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Layouts',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Escolha como as transmissões serão exibidas',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: LayoutMode.values.length,
              itemBuilder: (_, i) {
                final mode = LayoutMode.values[i];
                final isSelected = lm.mode == mode;
                return _LayoutCard(
                  mode: mode,
                  isSelected: isSelected,
                  onTap: () => context.read<LayoutManager>().changeLayout(mode),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutCard extends StatelessWidget {
  final LayoutMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayoutCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purpleDark.withOpacity(0.3) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.purple : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LayoutPreview(mode: mode, isSelected: isSelected),
              const SizedBox(height: 12),
              Text(
                mode.label,
                style: TextStyle(
                  color: isSelected ? AppColors.purpleLight : AppColors.onSurface,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${mode.maxStreams} stream${mode.maxStreams > 1 ? "s" : ""}',
                style: TextStyle(
                  color: isSelected ? AppColors.purpleLight.withOpacity(0.7) : AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayoutPreview extends StatelessWidget {
  final LayoutMode mode;
  final bool isSelected;

  const _LayoutPreview({required this.mode, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final baseColor = isSelected ? AppColors.purple : AppColors.surfaceVariant;
    final accentColor = isSelected ? AppColors.purpleLight : AppColors.border;

    return SizedBox(
      width: 72,
      height: 45,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          painter: _LayoutPainter(mode: mode, baseColor: baseColor, accentColor: accentColor),
        ),
      ),
    );
  }
}

class _LayoutPainter extends CustomPainter {
  final LayoutMode mode;
  final Color baseColor;
  final Color accentColor;

  _LayoutPainter({required this.mode, required this.baseColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final main = Paint()..color = baseColor.withOpacity(0.8);
    final pip = Paint()..color = accentColor.withOpacity(0.6);
    final bg = Paint()..color = Colors.black;
    final r = const Radius.circular(3);

    canvas.drawRect(Offset.zero & size, bg);

    switch (mode) {
      case LayoutMode.single:
        canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, r), main);
        break;
      case LayoutMode.splitTwo:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width / 2 - 1, size.height), r), main);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width / 2 + 1, 0, size.width / 2 - 1, size.height), r), pip);
        break;
      case LayoutMode.grid2x2:
        final hw = size.width / 2 - 1;
        final hh = size.height / 2 - 1;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, hw, hh), r), main);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(hw + 2, 0, hw, hh), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, hh + 2, hw, hh), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(hw + 2, hh + 2, hw, hh), r), pip);
        break;
      case LayoutMode.mainPip1:
        canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, r), main);
        final pw = size.width * 0.3;
        final ph = pw * 9 / 16;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - pw - 4, size.height - ph - 4, pw, ph), r), pip);
        break;
      case LayoutMode.mainPip2:
        canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, r), main);
        final pw = size.width * 0.28;
        final ph = pw * 9 / 16;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - pw - 4, size.height - ph - 4, pw, ph), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, size.height - ph - 4, pw, ph), r), pip);
        break;
      case LayoutMode.mainPip3:
        canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, r), main);
        final pw = size.width * 0.28;
        final ph = pw * 9 / 16;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - pw - 4, size.height - ph - 4, pw, ph), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, size.height - ph - 4, pw, ph), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - pw - 4, 4, pw, ph), r), pip);
        break;
      case LayoutMode.mainPip4:
        canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, r), main);
        final pw = size.width * 0.26;
        final ph = pw * 9 / 16;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, 4, pw, ph), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - pw - 4, 4, pw, ph), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, size.height - ph - 4, pw, ph), r), pip);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - pw - 4, size.height - ph - 4, pw, ph), r), pip);
        break;
    }
  }

  @override
  bool shouldRepaint(_LayoutPainter old) =>
      old.mode != mode || old.isSelected != isSelected;
}
