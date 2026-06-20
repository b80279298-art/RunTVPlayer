import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/favorite_manager.dart';
import '../managers/history_manager.dart';
import '../managers/stream_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';

class AddStreamScreen extends StatefulWidget {
  final StreamModel? editStream;

  const AddStreamScreen({super.key, this.editStream});

  @override
  State<AddStreamScreen> createState() => _AddStreamScreenState();
}

class _AddStreamScreenState extends State<AddStreamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  StreamType _selectedType = StreamType.m3u8;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editStream != null) {
      _urlCtrl.text = widget.editStream!.url;
      _nameCtrl.text = widget.editStream!.name;
      _selectedType = widget.editStream!.type;
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _detectType(String url) {
    setState(() => _selectedType = StreamTypeExtension.fromUrl(url));
  }

  Future<void> _play() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final sm = context.read<StreamManager>();
      final stream = await sm.addStream(
        name: _nameCtrl.text.trim().isEmpty
            ? _generateName(_urlCtrl.text.trim())
            : _nameCtrl.text.trim(),
        url: _urlCtrl.text.trim(),
        type: _selectedType,
      );
      await context.read<HistoryManager>().record(stream);
      if (mounted) Navigator.pop(context, stream);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _favorite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final sm = context.read<StreamManager>();
      final fm = context.read<FavoriteManager>();
      final stream = await sm.addStream(
        name: _nameCtrl.text.trim().isEmpty
            ? _generateName(_urlCtrl.text.trim())
            : _nameCtrl.text.trim(),
        url: _urlCtrl.text.trim(),
        type: _selectedType,
      );
      await fm.add(stream);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicionado aos favoritos!')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _generateName(String url) {
    try {
      final uri = Uri.parse(url);
      final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.last.replaceAll(RegExp(r'\.\w+$'), '');
    } catch (_) {}
    return 'Nova Transmissão';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adicionar Transmissão'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionLabel(text: 'URL da Transmissão'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlCtrl,
                style: const TextStyle(color: AppColors.onBackground),
                decoration: const InputDecoration(
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.link, color: AppColors.purple),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                onChanged: _detectType,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe a URL';
                  if (!Uri.tryParse(v.trim())!.isAbsolute) return 'URL inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _SectionLabel(text: 'Nome (opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.onBackground),
                decoration: const InputDecoration(
                  hintText: 'Nome da transmissão',
                  prefixIcon: Icon(Icons.label_outline, color: AppColors.purple),
                ),
              ),
              const SizedBox(height: 16),
              _SectionLabel(text: 'Tipo'),
              const SizedBox(height: 8),
              _TypeSelector(
                selected: _selectedType,
                onSelected: (t) => setState(() => _selectedType = t),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loading ? null : _play,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: const Text('Reproduzir'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loading ? null : _favorite,
                icon: const Icon(Icons.favorite_border),
                label: const Text('Adicionar aos Favoritos'),
              ),
              const SizedBox(height: 24),
              _RecentStreams(
                onSelect: (stream) {
                  setState(() {
                    _urlCtrl.text = stream.url;
                    _nameCtrl.text = stream.name;
                    _selectedType = stream.type;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}

class _TypeSelector extends StatelessWidget {
  final StreamType selected;
  final ValueChanged<StreamType> onSelected;

  const _TypeSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: StreamType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onSelected(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.purpleDark : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.purple : AppColors.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecentStreams extends StatelessWidget {
  final ValueChanged<StreamModel> onSelect;

  const _RecentStreams({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryManager>().history;
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Recentes'),
        const SizedBox(height: 10),
        ...history.take(5).map(
          (s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: AppColors.purple, size: 18),
            title: Text(s.name, style: const TextStyle(color: AppColors.onSurface, fontSize: 14)),
            subtitle: Text(s.url, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => onSelect(s),
          ),
        ),
      ],
    );
  }
}
