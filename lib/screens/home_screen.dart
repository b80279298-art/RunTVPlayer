import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/layout_manager.dart';
import '../managers/player_manager.dart';
import '../managers/settings_manager.dart';
import '../managers/history_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';
import 'add_stream_screen.dart';
import 'multi_player_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'layout_picker_screen.dart';
import 'volumes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final _pages = const [
    _PlayerPage(),
    LayoutPickerScreen(),
    FavoritesScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.purpleLight,
          unselectedItemColor: AppColors.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_quilt_outlined),
              activeIcon: Icon(Icons.view_quilt),
              label: 'Layouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Histórico',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerPage extends StatelessWidget {
  const _PlayerPage();

  @override
  Widget build(BuildContext context) {
    final lm = context.watch<LayoutManager>();
    final pm = context.watch<PlayerManager>();
    final settings = context.watch<SettingsManager>();

    return SafeArea(
      child: Column(
        children: [
          _Header(layoutMode: lm.mode),
          Expanded(
            child: lm.slots.any((s) => pm.getStream(s.slotId) != null)
                ? GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MultiPlayerScreen()),
                    ),
                    child: _PreviewGrid(lm: lm, pm: pm),
                  )
                : _EmptyState(
                    onAddStream: () => _addStream(context, lm, pm),
                  ),
          ),
          _BottomActions(
            onAddStream: () => _addStream(context, lm, pm),
            onOpenPlayer: () {
              if (lm.slots.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MultiPlayerScreen()),
                );
              }
            },
            onVolumes: () => _showVolumes(context),
          ),
        ],
      ),
    );
  }

  Future<void> _addStream(BuildContext context, LayoutManager lm, PlayerManager pm) async {
    final result = await Navigator.push<StreamModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddStreamScreen()),
    );
    if (result != null) {
      final emptySlot = lm.slots.firstWhere(
        (s) => pm.getStream(s.slotId) == null,
        orElse: () => lm.slots[0],
      );
      await pm.loadStream(emptySlot.slotId, result);
      context.read<HistoryManager>().record(result);
    }
  }

  void _showVolumes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const VolumesSheet(),
    );
  }
}

class _Header extends StatelessWidget {
  final LayoutMode layoutMode;
  const _Header({required this.layoutMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purpleDark, AppColors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.play_circle_filled, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'RunTV Player',
            style: TextStyle(
              color: AppColors.onBackground,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purpleDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.purple.withOpacity(0.4)),
            ),
            child: Text(
              layoutMode.label,
              style: const TextStyle(
                color: AppColors.purpleLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewGrid extends StatelessWidget {
  final LayoutManager lm;
  final PlayerManager pm;

  const _PreviewGrid({required this.lm, required this.pm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purpleDark.withOpacity(0.2), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.purple.withOpacity(0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.live_tv, color: AppColors.purpleLight, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Transmissões ativas',
                        style: TextStyle(
                          color: AppColors.purpleLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${lm.slots.where((s) => pm.getStream(s.slotId) != null).length}/${lm.slots.length}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...lm.slots.map((slot) {
                    final stream = pm.getStream(slot.slotId);
                    final state = pm.getState(slot.slotId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: slot.isMain ? AppColors.purple.withOpacity(0.6) : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stream != null
                                  ? (state?.isBuffering == true
                                      ? Colors.orange
                                      : state?.hasError == true
                                          ? AppColors.error
                                          : Colors.green)
                                  : AppColors.onSurfaceVariant.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              stream?.name ?? 'Slot vazio',
                              style: TextStyle(
                                color: stream != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: slot.isMain ? FontWeight.w600 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (slot.isMain)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PRINCIPAL',
                                style: TextStyle(color: AppColors.purpleLight, fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MultiPlayerScreen()),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Abrir Player'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddStream;
  const _EmptyState({required this.onAddStream});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.purpleDark.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stream,
                color: AppColors.purple,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma transmissão',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione um stream M3U8, MP4, MPEG-TS ou MPD para começar',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddStream,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Transmissão'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onAddStream;
  final VoidCallback onOpenPlayer;
  final VoidCallback onVolumes;

  const _BottomActions({
    required this.onAddStream,
    required this.onOpenPlayer,
    required this.onVolumes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAddStream,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onVolumes,
              icon: const Icon(Icons.volume_up, size: 18),
              label: const Text('Volumes'),
            ),
          ),
        ],
      ),
    );
  }
}
