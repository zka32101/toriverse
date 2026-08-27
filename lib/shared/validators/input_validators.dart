/// Input validation utilities for client-side validation
/// All server requests are also validated server-side in Cloud Functions

class InputValidators {
  /// Validate board position (0-63 for 8x8 board)
  /// Returns error message if invalid, null if valid
  static String? validateBoardPosition(int row, int col) {
    if (row < 0 || row > 7) {
      return 'Invalid row: $row (must be 0-7)';
    }
    if (col < 0 || col > 7) {
      return 'Invalid column: $col (must be 0-7)';
    }
    return null;
  }

  /// Validate display name
  /// Accepts: alphanumeric, underscore, dash, space
  /// Length: 1-32 characters
  static String? validateDisplayName(String name) {
    if (name.isEmpty) {
      return 'Display name cannot be empty';
    }
    if (name.length > 32) {
      return 'Display name must be 32 characters or less';
    }

    // Allow alphanumeric, underscore, dash, space, Japanese characters
    final validPattern = RegExp(r"^[a-zA-Z0-9_\-\s぀-ゟ゠-ヿ一-鿿]+$");
    if (!validPattern.hasMatch(name)) {
      return 'Display name contains invalid characters';
    }

    return null;
  }

  /// Validate UID (Firebase Auth UID format)
  /// Firebase UIDs are alphanumeric, 28 characters
  static String? validateUid(String uid) {
    if (uid.isEmpty) {
      return 'UID cannot be empty';
    }
    if (uid.length < 10 || uid.length > 128) {
      return 'Invalid UID length: ${uid.length}';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(uid)) {
      return 'UID contains invalid characters';
    }
    return null;
  }

  /// Validate email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validate password strength
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  /// Validate move submission (board position is in valid moves set)
  /// [row] - Board row (0-7)
  /// [col] - Board column (0-7)
  /// [validMoves] - List of valid move positions
  static String? validateMoveSubmission(
    int row,
    int col,
    List<({int row, int col})> validMoves,
  ) {
    // Check bounds first
    final boundsError = validateBoardPosition(row, col);
    if (boundsError != null) {
      return boundsError;
    }

    // Check if move is in valid set
    final isValid = validMoves.any((move) => move.row == row && move.col == col);
    if (!isValid) {
      return 'Position ($row, $col) is not a valid move';
    }

    return null;
  }

  /// Validate rank points (non-negative integer)
  static String? validateRankPoints(int points) {
    if (points < 0) {
      return 'Rank points cannot be negative';
    }
    if (points > 1000000) {
      return 'Rank points exceeds maximum';
    }
    return null;
  }

  /// Validate streak count
  static String? validateStreak(int streak) {
    if (streak < 0) {
      return 'Streak cannot be negative';
    }
    if (streak > 10000) {
      return 'Streak exceeds maximum';
    }
    return null;
  }

  /// Validate match ID (Firebase document ID format)
  static String? validateMatchId(String matchId) {
    if (matchId.isEmpty) {
      return 'Match ID cannot be empty';
    }
    if (matchId.length > 128) {
      return 'Match ID exceeds maximum length';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(matchId)) {
      return 'Match ID contains invalid characters';
    }
    return null;
  }

  /// Validate player list for match
  /// Must have exactly 3 players (humans or AIs)
  static String? validatePlayerList(List<String> playerIds) {
    if (playerIds.isEmpty) {
      return 'Player list cannot be empty';
    }
    if (playerIds.length != 3) {
      return 'Match must have exactly 3 players, got ${playerIds.length}';
    }
    for (final playerId in playerIds) {
      if (playerId.isEmpty) {
        return 'Player ID cannot be empty';
      }
      if (playerId.length > 128) {
        return 'Player ID exceeds maximum length';
      }
    }
    return null;
  }

  /// Validate round index (non-negative, less than max rounds)
  static String? validateRoundIndex(int roundIndex) {
    if (roundIndex < 0) {
      return 'Round index cannot be negative';
    }
    if (roundIndex > 64) {
      return 'Round index exceeds maximum (64 rounds for 8x8 board)';
    }
    return null;
  }

  /// Validate move submission count (between 0 and 3 for 3-player game)
  static String? validateMoveCount(int moveCount) {
    if (moveCount < 0 || moveCount > 3) {
      return 'Invalid move count: $moveCount (must be 0-3)';
    }
    return null;
  }

  /// Sanitize display name (remove unsafe characters)
  static String sanitizeDisplayName(String name) {
    // Remove control characters
    return name.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
  }

  /// Sanitize user input for logs (prevent injection)
  static String sanitizeForLogging(String input) {
    return input
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        .replaceAll('"', '\\"');
  }

  /// Check if string is UUID format
  static bool isUUID(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value);
  }
}

/// Validation results wrapper
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}

/// Extension for common validation patterns
extension StringValidation on String {
  bool get isValidEmail => InputValidators.validateEmail(this) == null;

  bool get isValidPassword => InputValidators.validatePassword(this) == null;

  bool get isValidDisplayName =>
      InputValidators.validateDisplayName(this) == null;

  bool get isValidUid => InputValidators.validateUid(this) == null;

  String get sanitized => InputValidators.sanitizeDisplayName(this);

  String get sanitizedForLogging =>
      InputValidators.sanitizeForLogging(this);
}

/// Extension for common number validation patterns
extension IntValidation on int {
  bool get isValidRankPoints => InputValidators.validateRankPoints(this) == null;

  bool get isValidStreak => InputValidators.validateStreak(this) == null;

  bool get isValidRoundIndex => InputValidators.validateRoundIndex(this) == null;
}
