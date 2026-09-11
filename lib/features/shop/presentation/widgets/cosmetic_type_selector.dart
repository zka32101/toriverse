import 'package:flutter/material.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Type selector widget for filtering cosmetics
class CosmeticTypeSelector extends StatelessWidget {
  final CosmeticType selectedType;
  final ValueChanged<CosmeticType> onTypeChanged;

  const CosmeticTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TypeChip(
            label: 'ボード',
            isSelected: selectedType == CosmeticType.board,
            onTap: () => onTypeChanged(CosmeticType.board),
          ),
          const SizedBox(width: 8),
          _TypeChip(
            label: '黒い石',
            isSelected: selectedType == CosmeticType.stoneBlack,
            onTap: () => onTypeChanged(CosmeticType.stoneBlack),
          ),
          const SizedBox(width: 8),
          _TypeChip(
            label: '白い石',
            isSelected: selectedType == CosmeticType.stoneWhite,
            onTap: () => onTypeChanged(CosmeticType.stoneWhite),
          ),
          const SizedBox(width: 8),
          _TypeChip(
            label: '赤い石',
            isSelected: selectedType == CosmeticType.stoneRed,
            onTap: () => onTypeChanged(CosmeticType.stoneRed),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue.shade300,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
