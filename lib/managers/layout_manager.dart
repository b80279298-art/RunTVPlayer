import 'package:flutter/material.dart';
import '../models/stream_model.dart';

class SlotConfig {
  final String slotId;
  final bool isMain;
  PipPosition? pipPosition;
  double pipFraction;
  bool isPinned;

  SlotConfig({
    required this.slotId,
    required this.isMain,
    this.pipPosition,
    this.pipFraction = 0.30,
    this.isPinned = false,
  });

  SlotConfig copyWith({
    String? slotId,
    bool? isMain,
    PipPosition? pipPosition,
    double? pipFraction,
    bool? isPinned,
  }) {
    return SlotConfig(
      slotId: slotId ?? this.slotId,
      isMain: isMain ?? this.isMain,
      pipPosition: pipPosition ?? this.pipPosition,
      pipFraction: pipFraction ?? this.pipFraction,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class LayoutManager extends ChangeNotifier {
  LayoutMode _mode;
  List<SlotConfig> _slots = [];
  double _globalPipFraction = 0.30;
  int _swappingFrom = -1;
  int _swappingTo = -1;

  LayoutManager(LayoutMode initialMode) : _mode = initialMode {
    _initSlots(initialMode);
  }

  LayoutMode get mode => _mode;
  List<SlotConfig> get slots => List.unmodifiable(_slots);
  double get globalPipFraction => _globalPipFraction;
  int get swappingFrom => _swappingFrom;
  int get swappingTo => _swappingTo;

  void _initSlots(LayoutMode mode) {
    switch (mode) {
      case LayoutMode.single:
        _slots = [SlotConfig(slotId: 'slot_0', isMain: true)];
        break;
      case LayoutMode.splitTwo:
        _slots = [
          SlotConfig(slotId: 'slot_0', isMain: true),
          SlotConfig(slotId: 'slot_1', isMain: false),
        ];
        break;
      case LayoutMode.grid2x2:
        _slots = List.generate(
          4,
          (i) => SlotConfig(slotId: 'slot_$i', isMain: i == 0),
        );
        break;
      case LayoutMode.mainPip1:
        _slots = [
          SlotConfig(slotId: 'slot_0', isMain: true),
          SlotConfig(slotId: 'slot_1', isMain: false, pipPosition: PipPosition.bottomRight, pipFraction: _globalPipFraction),
        ];
        break;
      case LayoutMode.mainPip2:
        _slots = [
          SlotConfig(slotId: 'slot_0', isMain: true),
          SlotConfig(slotId: 'slot_1', isMain: false, pipPosition: PipPosition.bottomRight, pipFraction: _globalPipFraction),
          SlotConfig(slotId: 'slot_2', isMain: false, pipPosition: PipPosition.bottomLeft, pipFraction: _globalPipFraction),
        ];
        break;
      case LayoutMode.mainPip3:
        _slots = [
          SlotConfig(slotId: 'slot_0', isMain: true),
          SlotConfig(slotId: 'slot_1', isMain: false, pipPosition: PipPosition.bottomRight, pipFraction: _globalPipFraction),
          SlotConfig(slotId: 'slot_2', isMain: false, pipPosition: PipPosition.bottomLeft, pipFraction: _globalPipFraction),
          SlotConfig(slotId: 'slot_3', isMain: false, pipPosition: PipPosition.topRight, pipFraction: _globalPipFraction),
        ];
        break;
      case LayoutMode.mainPip4:
        _slots = [
          SlotConfig(slotId: 'slot_0', isMain: true),
          SlotConfig(slotId: 'slot_1', isMain: false, pipPosition: PipPosition.topLeft, pipFraction: _globalPipFraction),
          SlotConfig(slotId: 'slot_2', isMain: false, pipPosition: PipPosition.topRight, pipFraction: _globalPipFraction),
          SlotConfig(slotId: 'slot_3', isMain: false, pipPosition: PipPosition.bottomLeft, pipFraction: _globalPipFraction),
          SlotConfig(slotId: 'slot_4', isMain: false, pipPosition: PipPosition.bottomRight, pipFraction: _globalPipFraction),
        ];
        break;
    }
  }

  void changeLayout(LayoutMode newMode) {
    final oldSlots = List<SlotConfig>.from(_slots);
    _mode = newMode;
    _initSlots(newMode);
    notifyListeners();
  }

  void swapMainWith(int secondaryIndex) {
    if (secondaryIndex < 0 || secondaryIndex >= _slots.length) return;
    final mainIndex = _slots.indexWhere((s) => s.isMain);
    if (mainIndex < 0 || mainIndex == secondaryIndex) return;

    _swappingFrom = mainIndex;
    _swappingTo = secondaryIndex;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mainIndex < _slots.length && secondaryIndex < _slots.length) {
        final mainSlotId = _slots[mainIndex].slotId;
        final secSlotId = _slots[secondaryIndex].slotId;
        final mainPip = _slots[mainIndex].pipPosition;
        final secPip = _slots[secondaryIndex].pipPosition;

        _slots[mainIndex] = _slots[mainIndex].copyWith(
          slotId: secSlotId,
          isMain: false,
          pipPosition: secPip ?? PipPosition.bottomRight,
        );
        _slots[secondaryIndex] = _slots[secondaryIndex].copyWith(
          slotId: mainSlotId,
          isMain: true,
          pipPosition: null,
        );
      }
      _swappingFrom = -1;
      _swappingTo = -1;
      notifyListeners();
    });
  }

  void setPipPosition(int slotIndex, PipPosition position) {
    if (slotIndex < 0 || slotIndex >= _slots.length) return;
    _slots[slotIndex] = _slots[slotIndex].copyWith(pipPosition: position);
    notifyListeners();
  }

  void setPipFraction(int slotIndex, double fraction, {bool allPips = false}) {
    final clamped = fraction.clamp(0.15, 0.45);
    if (allPips) {
      _globalPipFraction = clamped;
      for (int i = 0; i < _slots.length; i++) {
        if (!_slots[i].isMain) {
          _slots[i] = _slots[i].copyWith(pipFraction: clamped);
        }
      }
    } else {
      if (slotIndex < 0 || slotIndex >= _slots.length) return;
      _slots[slotIndex] = _slots[slotIndex].copyWith(pipFraction: clamped);
    }
    notifyListeners();
  }

  void setPinned(int slotIndex, bool pinned) {
    if (slotIndex < 0 || slotIndex >= _slots.length) return;
    _slots[slotIndex] = _slots[slotIndex].copyWith(isPinned: pinned);
    notifyListeners();
  }

  int get mainIndex => _slots.indexWhere((s) => s.isMain);

  SlotConfig? get mainSlot {
    final idx = mainIndex;
    return idx >= 0 ? _slots[idx] : null;
  }

  List<SlotConfig> get pipSlots => _slots.where((s) => !s.isMain).toList();

  bool get hasPips => pipSlots.isNotEmpty;
}
