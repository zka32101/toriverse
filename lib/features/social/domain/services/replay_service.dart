import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/replay_model.dart';

/// Service for managing replay sharing and viewing
class ReplayService {
  final FirebaseFirestore _firestore;

  const ReplayService(this._firestore);

  /// Save replay metadata
  Future<String> saveReplayMetadata({
    required String matchId,
    required String creatorUid,
    required String videoUrl,
    String? title,
    String? description,
    String? thumbnail,
    int? duration,
    bool isPublic = true,
  }) async {
    try {
      if (matchId.isEmpty || creatorUid.isEmpty || videoUrl.isEmpty) {
        throw Exception('Invalid replay parameters');
      }

      final replayDoc = await _firestore.collection('replays').add({
        'matchId': matchId,
        'creatorUid': creatorUid,
        'videoUrl': videoUrl,
        'title': title ?? 'Untitled Replay',
        'description': description,
        'thumbnail': thumbnail,
        'isPublic': isPublic,
        'tags': <String>[],
        'duration': duration,
        'createdAt': FieldValue.serverTimestamp(),
        'viewCount': 0,
        'shareCount': 0,
        'favoriteCount': 0,
      });

      // Add to user's shared replays subcollection
      await _firestore
          .collection('users')
          .doc(creatorUid)
          .collection('sharedReplays')
          .doc(replayDoc.id)
          .set({
            'replayId': replayDoc.id,
            'addedAt': FieldValue.serverTimestamp(),
          });

      return replayDoc.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get replay details
  Future<Replay?> getReplayDetails(String replayId) async {
    try {
      final doc = await _firestore
          .collection('replays')
          .doc(replayId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Replay.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Watch replay details as a stream
  Stream<Replay?> watchReplayDetails(String replayId) {
    return _firestore
        .collection('replays')
        .doc(replayId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Replay.fromJson(snapshot.data() as Map<String, dynamic>);
    }).handleError((e) {
      return null;
    });
  }

  /// Toggle replay visibility
  Future<void> toggleReplayVisibility({
    required String replayId,
    required String ownerUid,
  }) async {
    try {
      final doc = await _firestore
          .collection('replays')
          .doc(replayId)
          .get();

      if (!doc.exists) {
        throw Exception('Replay not found');
      }

      final replay = Replay.fromJson(doc.data() as Map<String, dynamic>);

      if (replay.creatorUid != ownerUid) {
        throw Exception('Only replay owner can modify visibility');
      }

      await doc.reference.update({
        'isPublic': !replay.isPublic,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Record a replay view
  Future<void> recordReplayView({
    required String replayId,
    required String viewerUid,
    int? durationWatched,
  }) async {
    try {
      if (replayId.isEmpty || viewerUid.isEmpty) {
        throw Exception('Invalid parameters');
      }

      final batch = _firestore.batch();

      // Increment view count
      final replayRef = _firestore.collection('replays').doc(replayId);
      batch.update(replayRef, {
        'viewCount': FieldValue.increment(1),
      });

      // Record view in subcollection (for later analytics)
      final viewRef = replayRef.collection('views').doc();
      batch.set(viewRef, {
        'viewedByUid': viewerUid,
        'viewedAt': FieldValue.serverTimestamp(),
        'duration': durationWatched,
      });

      await batch.commit();
    } catch (e) {
      // Silent failure - don't break the viewing experience
    }
  }

  /// Toggle favorite replay
  Future<void> toggleFavoriteReplay({
    required String replayId,
    required String userUid,
  }) async {
    try {
      if (replayId.isEmpty || userUid.isEmpty) {
        throw Exception('Invalid parameters');
      }

      final replayDoc = await _firestore
          .collection('replays')
          .doc(replayId)
          .get();

      if (!replayDoc.exists) {
        throw Exception('Replay not found');
      }

      final replay = Replay.fromJson(
        replayDoc.data() as Map<String, dynamic>,
      );

      // Check if already favorited
      final favDoc = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('favorites')
          .doc(replayId)
          .get();

      if (favDoc.exists) {
        // Remove favorite
        await favDoc.reference.delete();
        await replayDoc.reference.update({
          'favoriteCount': FieldValue.increment(-1),
        });
      } else {
        // Add favorite
        await favDoc.reference.set({
          'replayId': replayId,
          'favoritedAt': FieldValue.serverTimestamp(),
        });
        await replayDoc.reference.update({
          'favoriteCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Increment share count
  Future<void> incrementShareCount(String replayId) async {
    try {
      await _firestore.collection('replays').doc(replayId).update({
        'shareCount': FieldValue.increment(1),
      });
    } catch (e) {
      // Silent failure
    }
  }

  /// Add tags to a replay
  Future<void> addTagsToReplay({
    required String replayId,
    required List<String> tags,
    required String ownerUid,
  }) async {
    try {
      if (replayId.isEmpty || tags.isEmpty) {
        throw Exception('Invalid parameters');
      }

      final doc = await _firestore
          .collection('replays')
          .doc(replayId)
          .get();

      if (!doc.exists) {
        throw Exception('Replay not found');
      }

      final replay = Replay.fromJson(doc.data() as Map<String, dynamic>);

      if (replay.creatorUid != ownerUid) {
        throw Exception('Only replay owner can add tags');
      }

      // Merge new tags with existing
      final updatedTags = {...replay.tags, ...tags}.toList();

      await doc.reference.update({
        'tags': updatedTags,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a replay
  Future<void> deleteReplay({
    required String replayId,
    required String ownerUid,
  }) async {
    try {
      if (replayId.isEmpty || ownerUid.isEmpty) {
        throw Exception('Invalid parameters');
      }

      final replayDoc = await _firestore
          .collection('replays')
          .doc(replayId)
          .get();

      if (!replayDoc.exists) {
        throw Exception('Replay not found');
      }

      final replay = Replay.fromJson(
        replayDoc.data() as Map<String, dynamic>,
      );

      if (replay.creatorUid != ownerUid) {
        throw Exception('Only replay owner can delete');
      }

      final batch = _firestore.batch();

      // Delete replay
      batch.delete(replayDoc.reference);

      // Delete from user's shared replays
      batch.delete(
        _firestore
            .collection('users')
            .doc(ownerUid)
            .collection('sharedReplays')
            .doc(replayId),
      );

      // Delete all views
      final views = await replayDoc.reference.collection('views').get();
      for (final view in views.docs) {
        batch.delete(view.reference);
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's replays as a stream
  Stream<List<Replay>> getUserReplaysStream(String uid) {
    return _firestore
        .collectionGroup('sharedReplays')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .asyncMap((_) async {
      // Get all replay IDs from user's sharedReplays subcollection
      final replayIds = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sharedReplays')
          .get();

      final replays = <Replay>[];
      for (final doc in replayIds.docs) {
        final replayId = doc.id;
        final replayDoc = await _firestore
            .collection('replays')
            .doc(replayId)
            .get();

        if (replayDoc.exists) {
          replays.add(Replay.fromJson(
            replayDoc.data() as Map<String, dynamic>,
          ));
        }
      }

      return replays;
    }).handleError((e) {
      return [];
    });
  }

  /// Get public replays (discovery feed)
  Stream<List<Replay>> getPublicReplaysStream({
    int limit = 50,
  }) {
    return _firestore
        .collection('replays')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Replay.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Search replays by tag
  Future<List<Replay>> searchByTag(String tag) async {
    try {
      if (tag.isEmpty) {
        throw Exception('Tag cannot be empty');
      }

      final snapshot = await _firestore
          .collection('replays')
          .where('isPublic', isEqualTo: true)
          .where('tags', arrayContains: tag)
          .orderBy('viewCount', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Replay.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get trending replays
  Future<List<Replay>> getTrendingReplays({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('replays')
          .where('isPublic', isEqualTo: true)
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Replay.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if user has favorited a replay
  Future<bool> isFavorited({
    required String replayId,
    required String userUid,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('favorites')
          .doc(replayId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
