import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/favorite_manager.dart';
import '../managers/layout_manager.dart';
import '../managers/player_manager.dart';
import '../managers/history_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';
import '../screens/multi_player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fm = context.watch<FavoriteManager>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Favoritos',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: fm.favorites.isEmpty
                ? _EmptyFavorites()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: fm.favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _StreamCard(
                      stream: fm.favorites[i],
                      onPlay: () => _playStream(ctx, fm.favorites[i]),
                      onRemove: () => fm.remove(fm.favorites[i].id),
                    ),
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
}

class _StreamCard extends StatelessWidget {
  final StreamModel stream;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  const _StreamCard({
    required this.stream,
    required this.onPlay,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.purpleDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.live_tv, color: AppColors.purple, size: 20),
        ),
        title: Text(
          stream.name,
          style: const TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stream.url,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                stream.type.label,
                style: const TextStyle(color: AppColors.purpleLight, fontSize: 10),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle_filled, color: AppColors.purple, size: 28),
              onPressed: onPlay,
              tooltip: 'Reproduzir',
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.error, size: 22),
              onPressed: onRemove,
              tooltip: 'Remover dos favoritos',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: AppColors.purple.withOpacity(0.4), size: 64),
          const SizedBox(height: 16),
          const Text(
            'Nenhum favorito',
            style: TextStyle(color: AppColors.onBackground, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione transmissões aos favoritos para\nacesso rápido',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
