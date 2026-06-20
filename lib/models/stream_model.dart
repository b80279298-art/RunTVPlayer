import 'package:flutter/material.dart';

enum StreamType { m3u8, mp4, ts, mpd }

enum PipPosition { topLeft, topRight, bottomLeft, bottomRight }

enum LayoutMode {
  single,
  splitTwo,
  grid2x2,
  mainPip1,
  mainPip2,
  mainPip3,
  mainPip4,
}

enum PipSize { small, medium, large, custom }

extension StreamTypeExtension on StreamType {
  String get label {
    switch (this) {
      case StreamType.m3u8:
        return 'M3U8 (HLS)';
      case StreamType.mp4:
        return 'MP4';
      case StreamType.ts:
        return 'MPEG-TS';
      case StreamType.mpd:
        return 'MPD (DASH)';
    }
  }

  String get extension {
    switch (this) {
      case StreamType.m3u8:
        return '.m3u8';
      case StreamType.mp4:
        return '.mp4';
      case StreamType.ts:
        return '.ts';
      case StreamType.mpd:
        return '.mpd';
    }
  }

  static StreamType fromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8') || lower.contains('hls')) return StreamType.m3u8;
    if (lower.contains('.mpd') || lower.contains('dash')) return StreamType.mpd;
    if (lower.contains('.ts')) return StreamType.ts;
    return StreamType.mp4;
  }
}

extension LayoutModeExtension on LayoutMode {
  String get label {
    switch (this) {
      case LayoutMode.single:
        return 'Tela Única';
      case LayoutMode.splitTwo:
        return '2 Telas';
      case LayoutMode.grid2x2:
        return 'Grade 2×2';
      case LayoutMode.mainPip1:
        return 'Principal + 1 PiP';
      case LayoutMode.mainPip2:
        return 'Principal + 2 PiPs';
      case LayoutMode.mainPip3:
        return 'Principal + 3 PiPs';
      case LayoutMode.mainPip4:
        return 'Principal + 4 PiPs';
    }
  }

  IconData get icon {
    switch (this) {
      case LayoutMode.single:
        return Icons.crop_square;
      case LayoutMode.splitTwo:
        return Icons.view_agenda;
      case LayoutMode.grid2x2:
        return Icons.grid_view;
      case LayoutMode.mainPip1:
        return Icons.picture_in_picture;
      case LayoutMode.mainPip2:
        return Icons.view_quilt;
      case LayoutMode.mainPip3:
        return Icons.view_comfy;
      case LayoutMode.mainPip4:
        return Icons.view_module;
    }
  }

  int get maxStreams {
    switch (this) {
      case LayoutMode.single:
        return 1;
      case LayoutMode.splitTwo:
        return 2;
      case LayoutMode.grid2x2:
        return 4;
      case LayoutMode.mainPip1:
        return 2;
      case LayoutMode.mainPip2:
        return 3;
      case LayoutMode.mainPip3:
        return 4;
      case LayoutMode.mainPip4:
        return 5;
    }
  }
}

extension PipSizeExtension on PipSize {
  double get fraction {
    switch (this) {
      case PipSize.small:
        return 0.20;
      case PipSize.medium:
        return 0.30;
      case PipSize.large:
        return 0.40;
      case PipSize.custom:
        return 0.30;
    }
  }

  String get label {
    switch (this) {
      case PipSize.small:
        return 'Pequeno';
      case PipSize.medium:
        return 'Médio';
      case PipSize.large:
        return 'Grande';
      case PipSize.custom:
        return 'Personalizado';
    }
  }
}

class StreamModel {
  final String id;
  String name;
  String url;
  StreamType type;
  bool isFavorite;
  DateTime addedAt;
  DateTime? lastUsed;

  StreamModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.isFavorite = false,
    DateTime? addedAt,
    this.lastUsed,
  }) : addedAt = addedAt ?? DateTime.now();

  StreamModel copyWith({
    String? id,
    String? name,
    String? url,
    StreamType? type,
    bool? isFavorite,
    DateTime? addedAt,
    DateTime? lastUsed,
  }) {
    return StreamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'type': type.index,
    'isFavorite': isFavorite,
    'addedAt': addedAt.toIso8601String(),
    'lastUsed': lastUsed?.toIso8601String(),
  };

  factory StreamModel.fromJson(Map<String, dynamic> json) => StreamModel(
    id: json['id'] as String,
    name: json['name'] as String,
    url: json['url'] as String,
    type: StreamType.values[json['type'] as int],
    isFavorite: json['isFavorite'] as bool? ?? false,
    addedAt: DateTime.parse(json['addedAt'] as String),
    lastUsed: json['lastUsed'] != null
        ? DateTime.parse(json['lastUsed'] as String)
        : null,
  );

  @override
  bool operator ==(Object other) => other is StreamModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ActiveStream {
  final String id;
  StreamModel? stream;
  double volume;
  bool isPinned;
  bool isFavorited;
  int slotIndex;

  ActiveStream({
    required this.id,
    this.stream,
    this.volume = 1.0,
    this.isPinned = false,
    this.isFavorited = false,
    required this.slotIndex,
  });

  ActiveStream copyWith({
    String? id,
    StreamModel? stream,
    double? volume,
    bool? isPinned,
    bool? isFavorited,
    int? slotIndex,
  }) {
    return ActiveStream(
      id: id ?? this.id,
      stream: stream ?? this.stream,
      volume: volume ?? this.volume,
      isPinned: isPinned ?? this.isPinned,
      isFavorited: isFavorited ?? this.isFavorited,
      slotIndex: slotIndex ?? this.slotIndex,
    );
  }
}
