import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/history_manager.dart';
import '../managers/layout_manager.dart';
import '../managers/player_manager.dart';
import '../managers/favorite_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';
import '../screens/multi_player_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hm = context.watch<HistoryManager>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Histórico',
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (hm.history.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmClear(context, hm),
                    child: const Text('Limpar'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: hm.history.isEmpty
                ? _EmptyHistory()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: hm.history.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: AppColors.divider,
                      height: 1,
                    ),
                    itemBuilder: (ctx, i) {
                      final stream = hm.history[i];
                      return _HistoryItem(
                        stream: stream,
                        onPlay: () => _playStream(ctx, stream),
                        onRemove: () => hm.remove(stream.id),
                        onFavorite: () => context.read<FavoriteManager>().toggle(stream),
                        isFavorite: context.watch<FavoriteManager>().isFavorite(stream.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _playStream(BuildContext context, StreamModel stream) async {
    final lm = context.read<LayoutManager>();
    final pm = context.read<PlayerManager>();
    final emptySlot = lm.slots.firstWhere(
      (s) => pm.getStream(s.slotId) == null,
      orElse: () => lm.slots[0],
    );
    await pm.loadStream(emptySlot.slotId, stream);
    context.read<HistoryManager>().record(stream);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MultiPlayerScreen()),
    );
  }

  void _confirmClear(BuildContext context, HistoryManager hm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Limpar histórico', style: TextStyle(color: AppColors.onBackground)),
        content: const Text(
          'Deseja apagar todo o histórico?',
          style: TextStyle(color: AppColors.onSurface),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              hm.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Limpar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final StreamModel stream;
  final VoidCallback onPlay;
  final VoidCallback onRemove;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const _HistoryItem({
    required this.stream,
    required this.onPlay,
    required this.onRemove,
    required this.onFavorite,
    required this.isFavorite,
  });

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min atrás';
    if (diff.inDays < 1) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.history, color: AppColors.onSurfaceVariant, size: 20),
      ),
      title: Text(
        stream.name,
        style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        _timeAgo(stream.lastUsed),
        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : AppColors.onSurfaceVariant,
              size: 20,
            ),
            onPressed: onFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_filled, color: AppColors.purple, size: 26),
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: AppColors.purple.withOpacity(0.4), size: 64),
          const SizedBox(height: 16),
          const Text(
            'Nenhum histórico',
            style: TextStyle(color: AppColors.onBackground, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'As transmissões assistidas aparecerão aqui',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
