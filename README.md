# RunTV Player

Aplicativo Android de multivisão para transmissões M3U8, MP4, MPEG-TS e DASH.

## Funcionalidades

- **Multivisão**: Assista até 5 transmissões simultaneamente
- **Layouts**:
  - Tela única
  - Tela dividida em 2
  - Grade 2×2
  - Principal + 1, 2, 3 ou 4 PiPs
- **Troca de stream principal** com animação suave, sem recarregar
- **Volume independente** por stream (0–100%)
- **Buffer agressivo** para estabilidade (até 2GiB de cache)
- **Reconexão automática** em caso de perda de sinal
- **Mini-telas (PiP)** redimensionáveis com pinça (15%–45% da tela)
- **Gestos**: toque simples, duplo toque e pressão longa
- **Favoritos e histórico** persistidos localmente
- **Suporte a Android TV** e tablets

## Tecnologias

- Flutter 3.27+
- MediaKit (reprodução de vídeo)
- Material 3 / Tema escuro preto e roxo
- Provider (gerenciamento de estado)
- SharedPreferences (persistência)

## Formatos suportados

| Formato | Protocolo |
|---------|-----------|
| M3U8 | HLS |
| MP4 | HTTP |
| MPEG-TS | HTTP/UDP |
| MPD | MPEG-DASH |

## Como compilar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.27+
- Android SDK + NDK

### Build local

```bash
# Instalar dependências
flutter pub get

# Build APK debug
flutter build apk --debug

# Build APK release (por ABI)
flutter build apk --release --split-per-abi

# Build App Bundle
flutter build appbundle --release
```

### Via GitHub Actions

Ao fazer push para `main` ou `master`, o workflow `.github/workflows/build.yml` gera automaticamente:

- APKs debug e release (arm + arm64)
- App Bundle (.aab)
- Release no GitHub com os arquivos anexados

## Estrutura do projeto

```
lib/
├── main.dart                 # Entry point
├── theme/
│   └── app_theme.dart        # Tema Material 3 preto/roxo
├── models/
│   └── stream_model.dart     # Modelos de dados
├── managers/
│   ├── stream_manager.dart   # Gerenciamento de streams
│   ├── layout_manager.dart   # Gerenciamento de layouts
│   ├── player_manager.dart   # Gerenciamento de players (MediaKit)
│   ├── volume_manager.dart   # Volumes independentes
│   ├── favorite_manager.dart # Favoritos
│   ├── history_manager.dart  # Histórico
│   └── settings_manager.dart # Configurações
└── screens/
    ├── home_screen.dart
    ├── multi_player_screen.dart
    ├── add_stream_screen.dart
    ├── layout_picker_screen.dart
    ├── favorites_screen.dart
    ├── history_screen.dart
    ├── settings_screen.dart
    └── volumes_screen.dart
```

## Configurações de buffer

```
cache=yes
demuxer-thread=yes
demuxer-max-bytes=2GiB
demuxer-max-back-bytes=500MiB
demuxer-readahead-secs=300
cache-pause=yes
cache-pause-wait=30
network-timeout=90
stream-lavf-o=reconnect=1
```

## Gestos

| Gesto | Ação |
|-------|------|
| Toque simples | Trocar para stream principal |
| Duplo toque | Tela cheia |
| Pressionar e segurar | Menu de opções |

## Layouts disponíveis

| Layout | Streams | Descrição |
|--------|---------|-----------|
| Tela Única | 1 | Ocupa toda a tela |
| 2 Telas | 2 | Lado a lado |
| Grade 2×2 | 4 | Quatro streams em grade |
| Principal + 1 PiP | 2 | Um stream principal + mini-tela |
| Principal + 2 PiPs | 3 | Um principal + 2 mini-telas |
| Principal + 3 PiPs | 4 | Um principal + 3 mini-telas |
| Principal + 4 PiPs | 5 | Um principal + 4 mini-telas |

## Licença

MIT
