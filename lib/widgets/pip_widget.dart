import 'dart:async';
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
  
  double _sizeFraction = 0.30; 
  bool _showPipControls = false; // Controla se a borda e botões aparecem
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _entryAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryAnim, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryAnim, curve: const Interval(0.0, 1.0)),
    );
    _entryAnim.forward();
  }

  @override
  void dispose() {
    _entryAnim.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  // Ativa os controles e inicia o cronômetro para sumirem em 3 segundos
  void _togglePipControls() {
    setState(() {
      _showPipControls = !_showPipControls;
    });
    
    _hideTimer?.cancel();
    if (_showPipControls) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showPipControls = false);
        }
      });
    }
  }

  // Abre o menu para trocar a minitela de canto ao segurar o dedo
  void _openPositionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PipPositionMenu(
        slotIndex: widget.slotIndex,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  Offset _positionForConfig(SlotConfig config, Size pipSize) {
    const margin = 16.0;
    switch (config.pipPosition ?? PipPosition.topRight) {
      case PipPosition.topLeft:
        return const Offset(margin, margin);
      case PipPosition.topRight:
        return Offset(widget.screenSize.width - pipSize.width - margin, margin);
      case PipPosition.bottomLeft:
        return Offset(margin, widget.screenSize.height - pipSize.height - margin);
      case PipPosition.bottomRight:
        return Offset(
          widget.screenSize.width - pipSize.width - margin,
          widget.screenSize.height - pipSize.height - margin,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = context.watch<LayoutManager>();
    
    final pipW = widget.screenSize.width * _sizeFraction;
    final pipH = pipW * (9 / 16); 
    final pipSize = Size(pipW, pipH);
    final offset = _positionForConfig(widget.config, pipSize);

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      width: pipSize.width,
      height: pipSize.height,
      child: FadeTransition(
        opacity: _opacityAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: GestureDetector(
            onTap: _togglePipControls, // Clique simples: mostra/esconde bordas e botões
            onDoubleTap: () {
              // Clique duplo: alterna/inverte os canais entre tela grande e pequena
              lm.swapMainWith(widget.slotIndex);
            },
            onLongPress: _openPositionMenu, // Clique longo: abre menu para mudar de canto
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // A borda roxa só existe visualmente se _showPipControls for verdadeiro
                      border: Border.all(
                        color: _showPipControls ? AppColors.purple : Colors.transparent, 
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IgnorePointer(
                      // Bloqueia cliques internos no player para o GestureDetector de fora capturar o toque
                      child: PlayerWidget(
                        slotId: widget.config.slotId,
                        isMain: false,
                        isSwapping: widget.isSwapping,
                      ),
                    ),
                  ),
                ),

                // Os botões de zoom (+ e -) agora obedecem à visibilidade dinâmica
                if (_showPipControls)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Row(
                      children: [
                        _buildZoomButton(
                          icon: Icons.remove,
                          onPressed: () {
                            setState(() {
                              _sizeFraction = (_sizeFraction - 0.05).clamp(0.18, 0.45);
                            });
                            _togglePipControls(); // Reseta o cronômetro para não sumir enquanto clica
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildZoomButton(
                          icon: Icons.add,
                          onPressed: () {
                            setState(() {
                              _sizeFraction = (_sizeFraction + 0.05).clamp(0.18, 0.45);
                            });
                            _togglePipControls(); // Reseta o cronômetro para não sumir enquanto clica
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildZoomButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54, // Corrigido aqui também para o Flutter antigo aceitar!
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
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
