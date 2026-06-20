import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/layout_manager.dart';
import '../managers/player_manager.dart';
import '../managers/volume_manager.dart';
import '../theme/app_theme.dart';

class VolumesSheet extends StatelessWidget {
  const VolumesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final lm = context.watch<LayoutManager>();
    final pm = context.watch<PlayerManager>();
    final vm = context.watch<VolumeManager>();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (_, ctrl) => Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.volume_up, color: AppColors.purple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Controle de Volume',
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => vm.setAllVolumes(1.0),
                  child: const Text('Tudo 100%'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: lm.slots.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma transmissão ativa',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: lm.slots.length,
                      itemBuilder: (_, i) {
                        final slot = lm.slots[i];
                        final stream = pm.getStream(slot.slotId);
                        final volume = vm.getVolume(slot.slotId);
                        return _VolumeRow(
                          label: stream?.name ?? 'Slot ${i + 1}',
                          isMain: slot.isMain,
                          volume: volume,
                          onChanged: (v) => pm.setVolume(slot.slotId, v),
                          onMute: () => pm.setVolume(slot.slotId, volume > 0 ? 0 : 1.0),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  final String label;
  final bool isMain;
  final double volume;
  final ValueChanged<double> onChanged;
  final VoidCallback onMute;

  const _VolumeRow({
    required this.label,
    required this.isMain,
    required this.volume,
    required this.onChanged,
    required this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isMain)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRINCIPAL',
                    style: TextStyle(color: AppColors.purpleLight, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.purpleLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onMute,
                child: Icon(
                  volume == 0 ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.purple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: volume,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }
}
