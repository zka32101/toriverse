import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/cosmetics_providers.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';
import '../widgets/cosmetic_item_card.dart';
import '../widgets/cosmetic_type_selector.dart';

/// Main cosmetics shop screen
class CosmeticsShopScreen extends ConsumerStatefulWidget {
  const CosmeticsShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CosmeticsShopScreen> createState() =>
      _CosmeticsShopScreenState();
}

class _CosmeticsShopScreenState extends ConsumerState<CosmeticsShopScreen> {
  CosmeticType _selectedType = CosmeticType.board;

  @override
  Widget build(BuildContext context) {
    final cosmeticsByType =
        ref.watch(cosmeticsByTypeProvider(_selectedType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('コスメティックス'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            CosmeticTypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
            const SizedBox(height: 16),

            // Cosmetics list
            Expanded(
              child: cosmeticsByType.when(
                data: (cosmetics) {
                  if (cosmetics.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'コスメティックスがありません',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: cosmetics.length,
                    itemBuilder: (context, index) {
                      return CosmeticItemCard(
                        cosmetic: cosmetics[index],
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'エラー: ${error.toString()}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
