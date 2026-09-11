import 'package:flutter/material.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Section showing archived (unavailable) cosmetics from past seasons
class ArchivedCosmeticsSection extends StatefulWidget {
  final List<CosmeticItem> archivedCosmetics;

  const ArchivedCosmeticsSection({
    required this.archivedCosmetics,
    Key? key,
  }) : super(key: key);

  @override
  State<ArchivedCosmeticsSection> createState() =>
      _ArchivedCosmeticsSectionState();
}

class _ArchivedCosmeticsSectionState extends State<ArchivedCosmeticsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.archive,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '過去シーズン',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${widget.archivedCosmetics.length} 個を所有',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.archivedCosmetics.length,
                itemBuilder: (context, index) {
                  return _ArchivedCosmeticItem(
                    cosmetic: widget.archivedCosmetics[index],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ArchivedCosmeticItem extends StatelessWidget {
  final CosmeticItem cosmetic;

  const _ArchivedCosmeticItem({
    required this.cosmetic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.grey.shade100,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview (faded)
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
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),

              // Info (faded)
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
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        _getRarityLabel(cosmetic.rarity),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: Colors.grey.shade700,
                              fontSize: 9,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Archived badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '入手不可',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
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
