import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/shared/validators/input_validators.dart';

void main() {
  group('InputValidators - 盤面座標検証', () {
    test('有効な座標が承認される', () {
      expect(InputValidators.validateBoardPosition(0, 0), isNull);
      expect(InputValidators.validateBoardPosition(3, 3), isNull);
      expect(InputValidators.validateBoardPosition(7, 7), isNull);
      expect(InputValidators.validateBoardPosition(4, 2), isNull);
    });

    test('無効な行座標が拒否される', () {
      expect(InputValidators.validateBoardPosition(-1, 3), isNotNull);
      expect(InputValidators.validateBoardPosition(8, 3), isNotNull);
      expect(InputValidators.validateBoardPosition(100, 3), isNotNull);
    });

    test('無効な列座標が拒否される', () {
      expect(InputValidators.validateBoardPosition(3, -1), isNotNull);
      expect(InputValidators.validateBoardPosition(3, 8), isNotNull);
      expect(InputValidators.validateBoardPosition(3, 100), isNotNull);
    });

    test('境界値がチェックされる', () {
      // 最小値
      expect(InputValidators.validateBoardPosition(0, 0), isNull);
      // 最大値
      expect(InputValidators.validateBoardPosition(7, 7), isNull);
      // 範囲外
      expect(InputValidators.validateBoardPosition(-1, 0), isNotNull);
      expect(InputValidators.validateBoardPosition(8, 0), isNotNull);
    });
  });

  group('InputValidators - 表示名検証', () {
    test('有効な表示名が承認される', () {
      expect(InputValidators.validateDisplayName('Player_1'), isNull);
      expect(InputValidators.validateDisplayName('TestPlayer'), isNull);
      expect(InputValidators.validateDisplayName('プレイヤー1'), isNull);
      expect(InputValidators.validateDisplayName('Test-Player'), isNull);
      expect(InputValidators.validateDisplayName('Player 1'), isNull);
    });

    test('空の表示名が拒否される', () {
      expect(InputValidators.validateDisplayName(''), isNotNull);
    });

    test('長すぎる表示名が拒否される', () {
      final longName = 'A' * 33;
      expect(InputValidators.validateDisplayName(longName), isNotNull);
    });

    test('32文字の表示名が承認される', () {
      final validName = 'A' * 32;
      expect(InputValidators.validateDisplayName(validName), isNull);
    });

    test('無効な文字が拒否される', () {
      expect(InputValidators.validateDisplayName('Player@123'), isNotNull);
      expect(InputValidators.validateDisplayName('Player#1'), isNotNull);
      expect(InputValidators.validateDisplayName('Player$1'), isNotNull);
    });

    test('アルファベット、数字、アンダースコアが許可される', () {
      expect(InputValidators.validateDisplayName('Player_123'), isNull);
      expect(InputValidators.validateDisplayName('player_ABC'), isNull);
      expect(InputValidators.validateDisplayName('ABC123_xyz'), isNull);
    });
  });

  group('InputValidators - UID検証', () {
    test('有効なUIDが承認される', () {
      expect(
        InputValidators.validateUid(
          'abcd1234567890123456789012345678',
        ),
        isNull,
      );
      expect(InputValidators.validateUid('user_12345'), isNull);
      expect(InputValidators.validateUid('test-uid-123'), isNull);
    });

    test('空のUIDが拒否される', () {
      expect(InputValidators.validateUid(''), isNotNull);
    });

    test('短すぎるUIDが拒否される', () {
      expect(InputValidators.validateUid('abc'), isNotNull);
    });

    test('長すぎるUIDが拒否される', () {
      final longUid = 'a' * 200;
      expect(InputValidators.validateUid(longUid), isNotNull);
    });

    test('無効な文字が拒否される', () {
      expect(InputValidators.validateUid('user@123'), isNotNull);
      expect(InputValidators.validateUid('user#123'), isNotNull);
      expect(InputValidators.validateUid('user 123'), isNotNull);
    });
  });

  group('InputValidators - メール検証', () {
    test('有効なメールが承認される', () {
      expect(InputValidators.validateEmail('user@example.com'), isNull);
      expect(InputValidators.validateEmail('test.user@domain.co.jp'), isNull);
      expect(InputValidators.validateEmail('user+tag@example.com'), isNull);
    });

    test('無効なメール形式が拒否される', () {
      expect(InputValidators.validateEmail('invalid'), isNotNull);
      expect(InputValidators.validateEmail('user@'), isNotNull);
      expect(InputValidators.validateEmail('@example.com'), isNotNull);
      expect(InputValidators.validateEmail('user@example'), isNotNull);
    });

    test('空のメールが拒否される', () {
      expect(InputValidators.validateEmail(''), isNotNull);
    });
  });

  group('InputValidators - パスワード検証', () {
    test('強力なパスワードが承認される', () {
      expect(InputValidators.validatePassword('StrongPass123'), isNull);
      expect(InputValidators.validatePassword('Test@Password1'), isNull);
      expect(InputValidators.validatePassword('MyPassword123'), isNull);
    });

    test('短すぎるパスワードが拒否される', () {
      expect(InputValidators.validatePassword('Short1'), isNotNull);
    });

    test('大文字がないパスワードが拒否される', () {
      expect(InputValidators.validatePassword('password123'), isNotNull);
    });

    test('小文字がないパスワードが拒否される', () {
      expect(InputValidators.validatePassword('PASSWORD123'), isNotNull);
    });

    test('数字がないパスワードが拒否される', () {
      expect(InputValidators.validatePassword('PasswordNoNum'), isNotNull);
    });

    test('8文字以上が必須', () {
      expect(InputValidators.validatePassword('Pass123'), isNotNull);
      expect(InputValidators.validatePassword('Pass1234'), isNull);
    });
  });

  group('InputValidators - 手の投稿検証', () {
    test('有効な手が承認される', () {
      const validMoves = [
        (row: 2, col: 3),
        (row: 2, col: 4),
        (row: 3, col: 5),
      ];
      expect(
        InputValidators.validateMoveSubmission(2, 3, validMoves),
        isNull,
      );
      expect(
        InputValidators.validateMoveSubmission(2, 4, validMoves),
        isNull,
      );
    });

    test('無効な手が拒否される', () {
      const validMoves = [
        (row: 2, col: 3),
        (row: 2, col: 4),
      ];
      expect(
        InputValidators.validateMoveSubmission(0, 0, validMoves),
        isNotNull,
      );
      expect(
        InputValidators.validateMoveSubmission(4, 4, validMoves),
        isNotNull,
      );
    });

    test('境界外の手が拒否される', () {
      const validMoves = [
        (row: 2, col: 3),
      ];
      expect(
        InputValidators.validateMoveSubmission(-1, 3, validMoves),
        isNotNull,
      );
      expect(
        InputValidators.validateMoveSubmission(8, 3, validMoves),
        isNotNull,
      );
    });

    test('空の合法手リストでは手が拒否される', () {
      const validMoves = <({int row, int col})>[];
      expect(
        InputValidators.validateMoveSubmission(2, 3, validMoves),
        isNotNull,
      );
    });
  });

  group('InputValidators - ランクポイント検証', () {
    test('有効なランクポイントが承認される', () {
      expect(InputValidators.validateRankPoints(0), isNull);
      expect(InputValidators.validateRankPoints(100), isNull);
      expect(InputValidators.validateRankPoints(10000), isNull);
    });

    test('負のランクポイントが拒否される', () {
      expect(InputValidators.validateRankPoints(-1), isNotNull);
      expect(InputValidators.validateRankPoints(-100), isNotNull);
    });

    test('最大値を超えるランクポイントが拒否される', () {
      expect(InputValidators.validateRankPoints(2000000), isNotNull);
    });
  });

  group('InputValidators - ストリーク検証', () {
    test('有効なストリークが承認される', () {
      expect(InputValidators.validateStreak(0), isNull);
      expect(InputValidators.validateStreak(1), isNull);
      expect(InputValidators.validateStreak(100), isNull);
    });

    test('負のストリークが拒否される', () {
      expect(InputValidators.validateStreak(-1), isNotNull);
    });

    test('最大値を超えるストリークが拒否される', () {
      expect(InputValidators.validateStreak(20000), isNotNull);
    });
  });

  group('InputValidators - マッチID検証', () {
    test('有効なマッチIDが承認される', () {
      expect(InputValidators.validateMatchId('match_123'), isNull);
      expect(InputValidators.validateMatchId('match-456'), isNull);
      expect(InputValidators.validateMatchId('abc123def456'), isNull);
    });

    test('空のマッチIDが拒否される', () {
      expect(InputValidators.validateMatchId(''), isNotNull);
    });

    test('無効な文字が拒否される', () {
      expect(InputValidators.validateMatchId('match@123'), isNotNull);
      expect(InputValidators.validateMatchId('match#456'), isNotNull);
    });
  });

  group('InputValidators - プレイヤーリスト検証', () {
    test('3人のプレイヤーリストが承認される', () {
      expect(
        InputValidators.validatePlayerList(['player_1', 'player_2', 'AI_1']),
        isNull,
      );
    });

    test('空のリストが拒否される', () {
      expect(InputValidators.validatePlayerList([]), isNotNull);
    });

    test('1人のリストが拒否される', () {
      expect(InputValidators.validatePlayerList(['player_1']), isNotNull);
    });

    test('2人のリストが拒否される', () {
      expect(
        InputValidators.validatePlayerList(['player_1', 'player_2']),
        isNotNull,
      );
    });

    test('4人以上のリストが拒否される', () {
      expect(
        InputValidators.validatePlayerList([
          'player_1',
          'player_2',
          'player_3',
          'player_4'
        ]),
        isNotNull,
      );
    });

    test('空のプレイヤーIDが拒否される', () {
      expect(
        InputValidators.validatePlayerList(['player_1', '', 'AI_1']),
        isNotNull,
      );
    });
  });

  group('InputValidators - ラウンドインデックス検証', () {
    test('有効なラウンドインデックスが承認される', () {
      expect(InputValidators.validateRoundIndex(0), isNull);
      expect(InputValidators.validateRoundIndex(32), isNull);
      expect(InputValidators.validateRoundIndex(64), isNull);
    });

    test('負のラウンドインデックスが拒否される', () {
      expect(InputValidators.validateRoundIndex(-1), isNotNull);
    });

    test('最大値を超えるラウンドインデックスが拒否される', () {
      expect(InputValidators.validateRoundIndex(65), isNotNull);
    });
  });

  group('InputValidators - サニタイズ', () {
    test('表示名がサニタイズされる', () {
      final sanitized = InputValidators.sanitizeDisplayName('Player\x00Test');
      expect(sanitized, 'PlayerTest');
    });

    test('ログ用テキストがサニタイズされる', () {
      final sanitized = InputValidators.sanitizeForLogging('Line1\nLine2');
      expect(sanitized.contains('\\n'), true);
    });
  });

  group('InputValidators - UUID判定', () {
    test('有効なUUIDが検出される', () {
      expect(
        InputValidators.isUUID('550e8400-e29b-41d4-a716-446655440000'),
        true,
      );
    });

    test('無効なUUIDが検出される', () {
      expect(InputValidators.isUUID('not-a-uuid'), false);
      expect(InputValidators.isUUID('550e8400'), false);
    });
  });

  group('InputValidators - String拡張', () {
    test('isValidEmail拡張が機能する', () {
      expect('user@example.com'.isValidEmail, true);
      expect('invalid'.isValidEmail, false);
    });

    test('isValidPassword拡張が機能する', () {
      expect('StrongPass123'.isValidPassword, true);
      expect('weak'.isValidPassword, false);
    });

    test('isValidDisplayName拡張が機能する', () {
      expect('Player_1'.isValidDisplayName, true);
      expect(''.isValidDisplayName, false);
    });

    test('sanitized拡張が機能する', () {
      final result = 'Player\x00Test'.sanitized;
      expect(result, 'PlayerTest');
    });
  });

  group('InputValidators - Int拡張', () {
    test('isValidRankPoints拡張が機能する', () {
      expect((100).isValidRankPoints, true);
      expect((-1).isValidRankPoints, false);
    });

    test('isValidStreak拡張が機能する', () {
      expect((5).isValidStreak, true);
      expect((-1).isValidStreak, false);
    });

    test('isValidRoundIndex拡張が機能する', () {
      expect((32).isValidRoundIndex, true);
      expect((100).isValidRoundIndex, false);
    });
  });
}
