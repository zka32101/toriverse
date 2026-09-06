import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Seed data for cosmetics catalog
/// Contains default cosmetics for initial app setup and Firebase seeding
class CosmeticsSeedData {
  /// Board cosmetics (¥300)
  static const List<Map<String, dynamic>> boardCosmetics = [
    {
      'id': 'board_classic',
      'name': 'クラシック盤',
      'typeString': 'board',
      'priceJpy': 300,
      'description': '伝統的な木目調のオセロ盤。タイムレスな美しさ。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'board_midnight',
      'name': 'ミッドナイト盤',
      'typeString': 'board',
      'priceJpy': 300,
      'description': '深い紺色の盤。夜間プレイに最適。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'board_sakura',
      'name': 'さくら盤',
      'typeString': 'board',
      'priceJpy': 300,
      'description': '桜色をモチーフにした春らしい盤面。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'board_neon',
      'name': 'ネオン盤',
      'typeString': 'board',
      'priceJpy': 300,
      'description': '鮮やかなネオンカラーが目立つモダン盤。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'board_crystal',
      'name': 'クリスタル盤',
      'typeString': 'board',
      'priceJpy': 300,
      'description': '透明感のあるクリスタルをモチーフにした盤。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
  ];

  /// Black stone cosmetics (¥120)
  static const List<Map<String, dynamic>> stoneBlackCosmetics = [
    {
      'id': 'stone_black_classic',
      'name': 'クラシック黒石',
      'typeString': 'stoneBlack',
      'priceJpy': 120,
      'description': 'シンプルな黒い石。标准デザイン。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_black_marble',
      'name': 'マーブル黒石',
      'typeString': 'stoneBlack',
      'priceJpy': 120,
      'description': '大理石の質感が美しい黒石。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_black_midnight',
      'name': 'ミッドナイト黒石',
      'typeString': 'stoneBlack',
      'priceJpy': 120,
      'description': '深い紺色に近い神秘的な黒石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_black_obsidian',
      'name': '黒曜石',
      'typeString': 'stoneBlack',
      'priceJpy': 120,
      'description': '火山ガラスをモチーフにした艶やかな黒石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_black_shadow',
      'name': 'シャドウ黒石',
      'typeString': 'stoneBlack',
      'priceJpy': 120,
      'description': 'グラデーション効果で奥行きを表現した黒石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
  ];

  /// White stone cosmetics (¥120)
  static const List<Map<String, dynamic>> stoneWhiteCosmetics = [
    {
      'id': 'stone_white_classic',
      'name': 'クラシック白石',
      'typeString': 'stoneWhite',
      'priceJpy': 120,
      'description': 'シンプルな白い石。標準デザイン。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_white_pearl',
      'name': 'パール白石',
      'typeString': 'stoneWhite',
      'priceJpy': 120,
      'description': '真珠のような光沢を持つ白石。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_white_snow',
      'name': '雪色石',
      'typeString': 'stoneWhite',
      'priceJpy': 120,
      'description': '純白の雪をモチーフにした冬らしい白石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_white_frost',
      'name': 'フロスト白石',
      'typeString': 'stoneWhite',
      'priceJpy': 120,
      'description': '氷のような透明感と冷たさを表現した白石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_white_cloud',
      'name': 'クラウド白石',
      'typeString': 'stoneWhite',
      'priceJpy': 120,
      'description': '雲のようなふんわりした質感の白石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
  ];

  /// Red stone cosmetics (¥120)
  static const List<Map<String, dynamic>> stoneRedCosmetics = [
    {
      'id': 'stone_red_classic',
      'name': 'クラシック赤石',
      'typeString': 'stoneRed',
      'priceJpy': 120,
      'description': 'シンプルな赤い石。標準デザイン。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_red_cherry',
      'name': '桜石',
      'typeString': 'stoneRed',
      'priceJpy': 120,
      'description': '桜のような淡い赤色の石。',
      'rarity': 'common',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_red_crimson',
      'name': 'クリムゾン赤石',
      'typeString': 'stoneRed',
      'priceJpy': 120,
      'description': '深い深緋色の威厳ある赤石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_red_fire',
      'name': 'ファイア赤石',
      'typeString': 'stoneRed',
      'priceJpy': 120,
      'description': '炎のようなエネルギッシュな赤石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
    {
      'id': 'stone_red_ruby',
      'name': 'ルビー赤石',
      'typeString': 'stoneRed',
      'priceJpy': 120,
      'description': 'ルビーのような輝きと透明感の赤石。',
      'rarity': 'rare',
      'availableFrom': null,
      'availableUntil': null,
    },
  ];

  /// Limited edition cosmetics (¥500)
  static const List<Map<String, dynamic>> limitedEditionCosmetics = [
    {
      'id': 'limited_golden_set',
      'name': 'ゴールデンセット',
      'typeString': 'board',
      'priceJpy': 500,
      'description': '金色に輝く豪華な限定盤セット。所有者のみのエクスクルーシブデザイン。',
      'rarity': 'limited',
      'availableFrom': '2026-09-01T00:00:00Z',
      'availableUntil': '2026-09-30T23:59:59Z',
    },
    {
      'id': 'limited_platinum_stones',
      'name': 'プラチナストーン3色セット',
      'typeString': 'board',
      'priceJpy': 500,
      'description': 'プラチナを使用した究極の限定石3色セット。マッチの勝利をさらに輝かせます。',
      'rarity': 'limited',
      'availableFrom': '2026-09-01T00:00:00Z',
      'availableUntil': '2026-09-30T23:59:59Z',
    },
    {
      'id': 'limited_anniversary_board',
      'name': 'アニバーサリーボード',
      'typeString': 'board',
      'priceJpy': 500,
      'description': 'トリバース1周年を記念した特別限定盤。この期間のみ販売。',
      'rarity': 'limited',
      'availableFrom': '2026-09-15T00:00:00Z',
      'availableUntil': '2026-09-30T23:59:59Z',
    },
  ];

  /// Get all cosmetics as CosmeticItem objects
  static List<CosmeticItem> getAllCosmetics() {
    final allData = [
      ...boardCosmetics,
      ...stoneBlackCosmetics,
      ...stoneWhiteCosmetics,
      ...stoneRedCosmetics,
      ...limitedEditionCosmetics,
    ];

    return allData
        .map((data) => CosmeticItem.fromMap({
              'id': data['id'],
              'name': data['name'],
              'typeString': data['typeString'],
              'priceJpy': data['priceJpy'],
              'description': data['description'],
              'rarity': data['rarity'],
              'availableFrom': data['availableFrom'],
              'availableUntil': data['availableUntil'],
            }))
        .toList();
  }

  /// Get board cosmetics only
  static List<CosmeticItem> getBoardCosmetics() {
    return boardCosmetics
        .map((data) => CosmeticItem.fromMap({
              'id': data['id'],
              'name': data['name'],
              'typeString': data['typeString'],
              'priceJpy': data['priceJpy'],
              'description': data['description'],
              'rarity': data['rarity'],
              'availableFrom': data['availableFrom'],
              'availableUntil': data['availableUntil'],
            }))
        .toList();
  }

  /// Get stone cosmetics only
  static List<CosmeticItem> getStoneCosmetics() {
    final stoneData = [
      ...stoneBlackCosmetics,
      ...stoneWhiteCosmetics,
      ...stoneRedCosmetics,
    ];

    return stoneData
        .map((data) => CosmeticItem.fromMap({
              'id': data['id'],
              'name': data['name'],
              'typeString': data['typeString'],
              'priceJpy': data['priceJpy'],
              'description': data['description'],
              'rarity': data['rarity'],
              'availableFrom': data['availableFrom'],
              'availableUntil': data['availableUntil'],
            }))
        .toList();
  }

  /// Get limited edition cosmetics only
  static List<CosmeticItem> getLimitedEditionCosmetics() {
    return limitedEditionCosmetics
        .map((data) => CosmeticItem.fromMap({
              'id': data['id'],
              'name': data['name'],
              'typeString': data['typeString'],
              'priceJpy': data['priceJpy'],
              'description': data['description'],
              'rarity': data['rarity'],
              'availableFrom': data['availableFrom'],
              'availableUntil': data['availableUntil'],
            }))
        .toList();
  }
}
