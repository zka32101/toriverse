import 'package:flutter/material.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Grid display for cosmetic collection
class CollectionGrid extends StatelessWidget {
  final List<CosmeticItem> cosmetics;

  const CollectionGrid({
    required this.cosmetics,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cosmetics.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: cosmetics.length,
      itemBuilder: (context, index) {
        return _CosmeticGridItem(cosmetic: cosmetics[index]);
      },
    );
  }
}

class _CosmeticGridItem extends StatelessWidget {
  final CosmeticItem cosmetic;

  const _CosmeticGridItem({
    required this.cosmetic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _getCosmeticColor(cosmetic),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCosmeticIcon(cosmetic.type),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cosmetic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(cosmetic.rarity),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _getRarityLabel(cosmetic.rarity),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cosmetic.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: _getCosmeticColor(cosmetic),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getCosmeticIcon(cosmetic.type),
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                cosmetic.description ?? 'No description',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'レアリティ: ',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    _getRarityLabel(cosmetic.rarity),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Color _getCosmeticColor(CosmeticItem cosmetic) {
    switch (cosmetic.type) {
      case CosmeticType.board:
        return Colors.teal.shade400;
      case CosmeticType.stoneBlack:
        return Colors.grey.shade800;
      case CosmeticType.stoneWhite:
        return Colors.grey.shade200;
      case CosmeticType.stoneRed:
        return Colors.red.shade400;
    }
  }

  IconData _getCosmeticIcon(CosmeticType type) {
    switch (type) {
      case CosmeticType.board:
        return Icons.dashboard;
      case CosmeticType.stoneBlack:
      case CosmeticType.stoneWhite:
      case CosmeticType.stoneRed:
        return Icons.circle;
    }
  }

  Color _getRarityColor(CosmeticRarity rarity) {
    switch (rarity) {
      case CosmeticRarity.common:
        return Colors.grey;
      case CosmeticRarity.rare:
        return Colors.blue;
      case CosmeticRarity.limited:
        return Colors.amber;
    }
  }

  String _getRarityLabel(CosmeticRarity rarity) {
    switch (rarity) {
      case CosmeticRarity.common:
        return 'コモン';
      case CosmeticRarity.rare:
        return 'レア';
      case CosmeticRarity.limited:
        return '限定';
    }
  }
}
