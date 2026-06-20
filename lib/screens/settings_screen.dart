import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/settings_manager.dart';
import '../managers/layout_manager.dart';
import '../models/stream_model.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsManager>();
    final lm = context.watch<LayoutManager>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Configurações',
            style: TextStyle(
              color: AppColors.onBackground,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _Section(title: 'Aparência', children: [
            _SwitchTile(
              icon: Icons.animation,
              label: 'Animações',
              description: 'Ativar transições animadas',
              value: settings.animationsEnabled,
              onChanged: settings.setAnimationsEnabled,
            ),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Player', children: [
            _SwitchTile(
              icon: Icons.touch_app,
              label: 'Trocar por toque',
              description: 'Toque para trocar stream principal',
              value: settings.tapToSwitch,
              onChanged: settings.setTapToSwitch,
            ),
            _SwitchTile(
              icon: Icons.wifi_tethering,
              label: 'Reconexão automática',
              description: 'Reconectar ao perder a transmissão',
              value: settings.autoReconnect,
              onChanged: settings.setAutoReconnect,
            ),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Layout padrão', children: [
            ...LayoutMode.values.map((mode) => _RadioTile<LayoutMode>(
              label: mode.label,
              subtitle: '${mode.maxStreams} stream${mode.maxStreams > 1 ? "s" : ""}',
              value: mode,
              groupValue: settings.defaultLayout,
              onChanged: settings.setDefaultLayout,
            )),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Tamanho das mini-telas (PiP)', children: [
            ...PipSize.values.map((size) => _RadioTile<PipSize>(
              label: size.label,
              subtitle: size == PipSize.custom ? '15% a 45% da tela' : '${(size.fraction * 100).round()}% da tela',
              value: size,
              groupValue: settings.pipSize,
              onChanged: settings.setPipSize,
            )),
            if (settings.pipSize == PipSize.custom) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamanho: ${(settings.customPipFraction * 100).round()}%',
                      style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                    ),
                    Slider(
                      value: settings.customPipFraction,
                      min: 0.15,
                      max: 0.45,
                      divisions: 30,
                      onChanged: settings.setCustomPipFraction,
                    ),
                  ],
                ),
              ),
            ],
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Volume inicial', children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_up, color: AppColors.purple, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${(settings.defaultVolume * 100).round()}%',
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.defaultVolume,
                    min: 0,
                    max: 1,
                    divisions: 20,
                    onChanged: settings.setDefaultVolume,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Buffer', children: [
            ...settings.bufferSettings.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tune, color: AppColors.purple, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${e.key}: ',
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                          TextSpan(
                            text: e.value,
                            style: const TextStyle(
                              color: AppColors.purpleLight,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ]),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'RunTV Player v1.0.0',
              style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.purple, size: 20),
      title: Text(label, style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(description, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final String label;
  final String? subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  const _RadioTile({
    required this.label,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.purpleLight : AppColors.onSurface,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11))
          : null,
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: (v) => onChanged(v as T),
        activeColor: AppColors.purple,
      ),
      onTap: () => onChanged(value),
    );
  }
}
