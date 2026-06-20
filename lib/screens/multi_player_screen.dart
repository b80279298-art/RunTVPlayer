import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../managers/layout_manager.dart';
import '../managers/player_manager.dart';
import '../managers/settings_manager.dart';
import '../managers/volume_manager.dart';
import '../managers/history_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';
import '../widgets/player_widget.dart';
import '../widgets/pip_widget.dart';
import 'add_stream_screen.dart';

class MultiPlayerScreen extends StatefulWidget {
  const MultiPlayerScreen({super.key});

  @override
  State<MultiPlayerScreen> createState() => _MultiPlayerScreenState();
}

class _MultiPlayerScreenState extends State<MultiPlayerScreen>
    with TickerProviderStateMixin {
  bool _showControls = false;
  bool _fullscreenMode = false;
  int? _fullscreenSlot;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  void _enterFullscreen(int slotIndex) {
    setState(() {
      _fullscreenMode = true;
      _fullscreenSlot = slotIndex;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() {
    setState(() {
      _fullscreenMode = false;
      _fullscreenSlot = null;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _showSlotMenu(BuildContext context, int slotIndex) {
    final lm = context.read<LayoutManager>();
    final pm = context.read<PlayerManager>();
    final vm = context.read<VolumeManager>();
    final slotId = lm.slots[slotIndex].slotId;
    final stream = pm.getStream(slotId);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SlotMenuSheet(
        slotIndex: slotIndex,
        slotId: slotId,
        stream: stream,
        volume: vm.getVolume(slotId),
        onChangeUrl: () async {
          Navigator.pop(ctx);
          final result = await Navigator.push<StreamModel>(
            context,
            MaterialPageRoute(builder: (_) => const AddStreamScreen()),
          );
          if (result != null && mounted) {
            await pm.loadStream(slotId, result);
            context.read<HistoryManager>().record(result);
          }
        },
        onClose: () {
          Navigator.pop(ctx);
          pm.removeSlot(slotId);
        },
        onVolumeChange: (v) => pm.setVolume(slotId, v),
        onPinToggle: () {
          Navigator.pop(ctx);
          lm.setPinned(slotIndex, !lm.slots[slotIndex].isPinned);
        },
        onPositionChange: (pos) {
          Navigator.pop(ctx);
          lm.setPipPosition(slotIndex, pos);
        },
        isMain: lm.slots[slotIndex].isMain,
      ),
    );
  }

  Widget _buildSingleLayout(LayoutManager lm, Size size) {
    final slot = lm.slots[0];
    return PlayerWidget(
      slotId: slot.slotId,
      isMain: true,
      showOverlay: _showControls,
      onTap: _toggleControls,
      onDoubleTap: () => _enterFullscreen(0),
      onLongPress: () => _showSlotMenu(context, 0),
    );
  }

  Widget _buildSplitTwoLayout(LayoutManager lm, Size size) {
    return Row(
      children: [
        for (int i = 0; i < lm.slots.length && i < 2; i++)
          Expanded(
            child: PlayerWidget(
              slotId: lm.slots[i].slotId,
              isMain: i == 0,
              showOverlay: _showControls,
              onTap: () {
                if (i != lm.mainIndex) {
                  lm.swapMainWith(i);
                } else {
                  _toggleControls();
                }
              },
              onDoubleTap: () => _enterFullscreen(i),
              onLongPress: () => _showSlotMenu(context, i),
            ),
          ),
      ],
    );
  }

  Widget _buildGrid2x2Layout(LayoutManager lm, Size size) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 9,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: lm.slots.length.clamp(0, 4),
      itemBuilder: (_, i) => PlayerWidget(
        slotId: lm.slots[i].slotId,
        isMain: lm.slots[i].isMain,
        showOverlay: _showControls,
        onTap: () {
          if (!lm.slots[i].isMain) {
            lm.swapMainWith(i);
          } else {
            _toggleControls();
          }
        },
        onDoubleTap: () => _enterFullscreen(i),
        onLongPress: () => _showSlotMenu(context, i),
      ),
    );
  }

  Widget _buildMainPipLayout(LayoutManager lm, Size size) {
    final mainSlot = lm.mainSlot;
    if (mainSlot == null) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        PlayerWidget(
          slotId: mainSlot.slotId,
          isMain: true,
          showOverlay: _showControls,
          onTap: _toggleControls,
          onDoubleTap: () => _enterFullscreen(lm.mainIndex),
          onLongPress: () => _showSlotMenu(context, lm.mainIndex),
        ),
        for (int i = 0; i < lm.slots.length; i++)
          if (!lm.slots[i].isMain)
            PipWidget(
              key: ValueKey(lm.slots[i].slotId),
              slotIndex: i,
              config: lm.slots[i],
              screenSize: size,
              onTap: () => lm.swapMainWith(i),
              onDoubleTap: () => _enterFullscreen(i),
              onLongPress: () => _showSlotMenu(context, i),
              isSwapping: lm.swappingTo == i,
            ),
      ],
    );
  }

  Widget _buildLayout(LayoutManager lm, Size size) {
    switch (lm.mode) {
      case LayoutMode.single:
        return _buildSingleLayout(lm, size);
      case LayoutMode.splitTwo:
        return _buildSplitTwoLayout(lm, size);
      case LayoutMode.grid2x2:
        return _buildGrid2x2Layout(lm, size);
      case LayoutMode.mainPip1:
      case LayoutMode.mainPip2:
      case LayoutMode.mainPip3:
      case LayoutMode.mainPip4:
        return _buildMainPipLayout(lm, size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = context.watch<LayoutManager>();
    final size = MediaQuery.of(context).size;

    if (_fullscreenMode && _fullscreenSlot != null) {
      final idx = _fullscreenSlot!;
      final slotId = idx < lm.slots.length ? lm.slots[idx].slotId : null;
      if (slotId != null) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: _exitFullscreen,
            child: Stack(
              children: [
                PlayerWidget(
                  slotId: slotId,
                  isMain: true,
                  onTap: _exitFullscreen,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                      onPressed: _exitFullscreen,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildLayout(lm, size),
          if (_showControls) _ControlsOverlay(onDismiss: _toggleControls),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const _ControlsOverlay({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ControlButton(
                    icon: Icons.settings,
                    onTap: () {
                      onDismiss();
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.purple.withOpacity(0.6)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SlotMenuSheet extends StatefulWidget {
  final int slotIndex;
  final String slotId;
  final StreamModel? stream;
  final double volume;
  final VoidCallback onChangeUrl;
  final VoidCallback onClose;
  final ValueChanged<double> onVolumeChange;
  final VoidCallback onPinToggle;
  final ValueChanged<PipPosition> onPositionChange;
  final bool isMain;

  const _SlotMenuSheet({
    required this.slotIndex,
    required this.slotId,
    required this.stream,
    required this.volume,
    required this.onChangeUrl,
    required this.onClose,
    required this.onVolumeChange,
    required this.onPinToggle,
    required this.onPositionChange,
    required this.isMain,
  });

  @override
  State<_SlotMenuSheet> createState() => _SlotMenuSheetState();
}

class _SlotMenuSheetState extends State<_SlotMenuSheet> {
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.volume;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.stream != null) ...[
            Text(
              widget.stream!.name,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Text(
              widget.stream!.url,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              const Icon(Icons.volume_up, color: AppColors.purple, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _volume,
                  onChanged: (v) {
                    setState(() => _volume = v);
                    widget.onVolumeChange(v);
                  },
                  min: 0,
                  max: 1,
                  divisions: 20,
                ),
              ),
              Text(
                '${(_volume * 100).round()}%',
                style: const TextStyle(color: AppColors.onSurface, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.link,
            label: 'Alterar URL',
            onTap: widget.onChangeUrl,
          ),
          if (!widget.isMain)
            _MenuItem(
              icon: Icons.push_pin_outlined,
              label: widget.slotIndex < context.read<LayoutManager>().slots.length
                  ? (context.read<LayoutManager>().slots[widget.slotIndex].isPinned ? 'Desafixar' : 'Fixar posição')
                  : 'Fixar posição',
              onTap: widget.onPinToggle,
            ),
          _MenuItem(
            icon: Icons.close,
            label: 'Fechar transmissão',
            textColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: widget.onClose,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.purple, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.onSurface,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
