const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

// ============================================================================
// CONSTANTS
// ============================================================================

// 3-color Othello board representation
const BOARD_EMPTY = -1;
const BOARD_BLACK = 0;
const BOARD_WHITE = 1;
const BOARD_RED = 2;

// Directions: 8 adjacent cells (N, NE, E, SE, S, SW, W, NW)
const DIRECTIONS = [
  [-1, 0], // N
  [-1, 1], // NE
  [0, 1], // E
  [1, 1], // SE
  [1, 0], // S
  [1, -1], // SW
  [0, -1], // W
  [-1, -1], // NW
];

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Convert 0-63 position to [row, col]
 */
function posToRowCol(pos) {
  return [Math.floor(pos / 8), pos % 8];
}

/**
 * Convert [row, col] to 0-63 position
 */
function rowColToPos(row, col) {
  return row * 8 + col;
}

/**
 * Get adjacent positions in all 8 directions from a position
 */
function getAdjacentInDirection(pos, direction) {
  const [row, col] = posToRowCol(pos);
  const [dRow, dCol] = direction;
  const newRow = row + dRow;
  const newCol = col + dCol;

  if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
    return rowColToPos(newRow, newCol);
  }
  return null;
}

/**
 * Check if a move is valid (legal) for a player
 * A move is valid if it results in at least one flip
 */
function validateMove(boardState, playerColor, position) {
  // Check if position is empty
  if (boardState[position] !== BOARD_EMPTY) {
    return { isValid: false, flipped: [] };
  }

  const flipped = [];

  // Check all 8 directions
  for (const direction of DIRECTIONS) {
    const dirFlipped = getFlippedInDirection(boardState, playerColor, position, direction);
    if (dirFlipped.length > 0) {
      flipped.push(...dirFlipped);
    }
  }

  return {
    isValid: flipped.length > 0,
    flipped: [...new Set(flipped)], // remove duplicates
  };
}

/**
 * Get flipped positions in a specific direction
 */
function getFlippedInDirection(boardState, playerColor, position, direction) {
  const flipped = [];
  let currentPos = position;

  while (true) {
    currentPos = getAdjacentInDirection(currentPos, direction);
    if (currentPos === null) break;

    const stone = boardState[currentPos];
    if (stone === BOARD_EMPTY) break;
    if (stone === playerColor) {
      return flipped;
    }

    flipped.push(currentPos);
  }

  return [];
}

/**
 * Apply move to board
 */
function applyMove(boardState, playerColor, position, flipped) {
  const newBoard = [...boardState];
  newBoard[position] = playerColor;
  for (const pos of flipped) {
    newBoard[pos] = playerColor;
  }
  return newBoard;
}

/**
 * Count stones by color
 */
function countStones(boardState) {
  const counts = [0, 0, 0];
  for (const stone of boardState) {
    if (stone >= 0 && stone < 3) {
      counts[stone]++;
    }
  }
  return counts;
}

/**
 * Check if weak bonus should activate
 */
function shouldActivateWeakBonus(playerStoneCount, allCounts, roundIndex, weakBonusState) {
  if (roundIndex > 11) return false;
  if (weakBonusState.remainingActivations <= 0) return false;
  if (weakBonusState.lastActivatedRound === roundIndex) return false;

  const sortedCounts = [...allCounts].sort((a, b) => a - b);
  const threshold = sortedCounts[0];
  return playerStoneCount <= threshold;
}

/**
 * Generate replay animation events
 */
function generateReplayEvents(processOrder, moveResults) {
  const events = [];
  let step = 0;
  let delayMs = 0;

  for (const playerId of processOrder) {
    const result = moveResults[playerId];
    if (!result) continue;

    delayMs += 300;

    events.push({
      step: step++,
      type: "move",
      playerId: playerId,
      position: result.position,
      delayMs: delayMs,
    });

    for (const flippedPos of result.flipped) {
      delayMs += 100;
      events.push({
        step: step++,
        type: "flip",
        position: flippedPos,
        delayMs: delayMs,
      });
    }
  }

  return events;
}

// ============================================================================
// CLOUD FUNCTIONS
// ============================================================================

/**
 * submitMove - Client submits a move for the current round
 */
exports.submitMove = functions.https.onCall(async (data, context) => {
  const { matchId, roundIndex, playerId, position } = data;

  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  if (context.auth.uid !== playerId) {
    throw new functions.https.HttpsError("permission-denied", "User can only submit their own move");
  }

  if (typeof matchId !== "string" || typeof roundIndex !== "number" || typeof position !== "number") {
    throw new functions.https.HttpsError("invalid-argument", "Invalid move submission data");
  }

  if (position < 0 || position > 63) {
    throw new functions.https.HttpsError("invalid-argument", "Position out of bounds");
  }

  try {
    await db
      .collection("matches")
      .doc(matchId)
      .collection("submissions")
      .doc(`${roundIndex}_${playerId}`)
      .set({
        roundIndex: roundIndex,
        playerId: playerId,
        position: position,
        submittedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { success: true };
  } catch (error) {
    console.error("Error submitting move:", error);
    throw new functions.https.HttpsError("internal", "Failed to submit move");
  }
});

/**
 * validateMove - Validate a move before processing
 */
exports.validateMove = functions.https.onCall(async (data, context) => {
  const { boardState, playerColor, position } = data;

  if (!Array.isArray(boardState) || boardState.length !== 64) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid board state");
  }

  if (typeof playerColor !== "number" || playerColor < 0 || playerColor > 2) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid player color");
  }

  if (typeof position !== "number" || position < 0 || position > 63) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid position");
  }

  const result = validateMove(boardState, playerColor, position);
  return result;
});

/**
 * resolveCollision - Resolve same-position submissions
 */
exports.resolveCollision = functions.https.onCall(async (data, context) => {
  const { matchId, position, playerIds, roundIndex } = data;

  if (!Array.isArray(playerIds) || playerIds.length < 2) {
    throw new functions.https.HttpsError("invalid-argument", "At least 2 players required for collision");
  }

  const winnerIdx = Math.floor(Math.random() * playerIds.length);
  const winnerId = playerIds[winnerIdx];
  const loserIds = playerIds.filter((_, i) => i !== winnerIdx);

  try {
    const batch = db.batch();

    for (const loserId of loserIds) {
      const rescueCardRef = db
        .collection("matches")
        .doc(matchId)
        .collection("rescueCards")
        .doc(`${loserId}_${roundIndex}`);

      batch.set(
        rescueCardRef,
        {
          matchId: matchId,
          playerId: loserId,
          consecutiveAttackedCount: 1,
          cardAvailable: true,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    await batch.commit();

    return {
      winner: winnerId,
      losers: loserIds,
      rescueCardGranted: true,
    };
  } catch (error) {
    console.error("Error resolving collision:", error);
    throw new functions.https.HttpsError("internal", "Failed to resolve collision");
  }
});

/**
 * processBonusLogic - Apply weak bonus and rescue card effects
 */
exports.processBonusLogic = functions.https.onCall(async (data, context) => {
  const { matchId, roundIndex, playerMoves, boardState } = data;

  try {
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Match not found");
    }

    const matchData = matchDoc.data();
    const players = matchData.players;

    const weakBonusRef = db.collection("matches").doc(matchId).collection("weakBonuses").doc("state");
    const weakBonusDoc = await weakBonusRef.get();
    let weakBonusState = weakBonusDoc.exists
      ? weakBonusDoc.data()
      : {
          matchId: matchId,
          remainingActivations: 2,
          lastActivatedRound: -1,
          benefitedPlayerIds: [],
        };

    const stoneCounts = countStones(boardState);
    const bonusActivations = [];

    for (let i = 0; i < players.length; i++) {
      const playerId = players[i];
      const playerStones = stoneCounts[i];

      if (shouldActivateWeakBonus(playerStones, stoneCounts, roundIndex, weakBonusState)) {
        bonusActivations.push(playerId);
        weakBonusState.lastActivatedRound = roundIndex;
        weakBonusState.remainingActivations--;
        if (!weakBonusState.benefitedPlayerIds.includes(playerId)) {
          weakBonusState.benefitedPlayerIds.push(playerId);
        }
      }
    }

    await weakBonusRef.set(weakBonusState, { merge: true });

    return {
      bonusActivated: bonusActivations,
      remainingActivations: weakBonusState.remainingActivations,
    };
  } catch (error) {
    console.error("Error processing bonus logic:", error);
    throw new functions.https.HttpsError("internal", "Failed to process bonus logic");
  }
});

/**
 * processRound - Main round processing orchestrator
 */
exports.processRound = functions.pubsub.topic("process_round").onPublish(async (message) => {
  const { matchId, roundIndex } = JSON.parse(Buffer.from(message.data, "base64").toString());

  console.log(`Processing round ${roundIndex} for match ${matchId}`);

  try {
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) {
      console.error(`Match ${matchId} not found`);
      return;
    }

    const matchData = matchDoc.data();
    const players = matchData.players;
    let boardState = matchData.boardState;

    const submissionsSnap = await db
      .collection("matches")
      .doc(matchId)
      .collection("submissions")
      .where("roundIndex", "==", roundIndex)
      .get();

    const submissions = submissionsSnap.docs.map((doc) => doc.data());

    if (submissions.length !== 3) {
      console.warn(`Expected 3 submissions for round ${roundIndex}, got ${submissions.length}`);
      return;
    }

    const positionMap = {};
    const moveResults = {};

    for (const submission of submissions) {
      const { playerId, position } = submission;
      const playerIdx = players.indexOf(playerId);

      if (!positionMap[position]) {
        positionMap[position] = [];
      }
      positionMap[position].push({ playerId, playerIdx });
    }

    let processOrder = [...players];
    for (let i = processOrder.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [processOrder[i], processOrder[j]] = [processOrder[j], processOrder[i]];
    }

    const replayEvents = [];
    const collisions = [];

    for (const [position, submitters] of Object.entries(positionMap)) {
      const pos = parseInt(position);

      if (submitters.length > 1) {
        const result = await db
          .collection("collisionResolutions")
          .doc(`${matchId}_${roundIndex}_${pos}`)
          .get()
          .then((doc) => {
            if (doc.exists) return doc.data();
            return null;
          });

        if (result) {
          collisions.push({
            position: pos,
            winner: result.winner,
            losers: result.losers,
            rescueCardGranted: result.rescueCardGranted,
          });

          const winnerId = result.winner;
          const playerIdx = players.indexOf(winnerId);
          const playerColor = playerIdx;

          const validation = validateMove(boardState, playerColor, pos);
          if (validation.isValid) {
            moveResults[winnerId] = {
              position: pos,
              playerColor: playerColor,
              flipped: validation.flipped,
            };
            boardState = applyMove(boardState, playerColor, pos, validation.flipped);
          }
        }
      } else {
        const submission = submitters[0];
        const { playerId, playerIdx } = submission;
        const playerColor = playerIdx;

        const validation = validateMove(boardState, playerColor, pos);
        if (validation.isValid) {
          moveResults[playerId] = {
            position: pos,
            playerColor: playerColor,
            flipped: validation.flipped,
          };
          boardState = applyMove(boardState, playerColor, pos, validation.flipped);
        }
      }
    }

    const bonusResult = await db
      .collection("matches")
      .doc(matchId)
      .collection("weakBonuses")
      .doc("state")
      .get()
      .then((doc) => {
        if (doc.exists) return doc.data();
        return { bonusActivated: [] };
      });

    const events = generateReplayEvents(processOrder, moveResults);
    const stoneCounts = countStones(boardState);

    const roundResultRef = db
      .collection("matches")
      .doc(matchId)
      .collection("roundResults")
      .doc(`round_${roundIndex}`);

    await roundResultRef.set({
      matchId: matchId,
      roundIndex: roundIndex,
      submittedMoves: submissions,
      collisionResolved: collisions,
      processOrder: processOrder,
      replayEvents: events,
      boardStateAfter: boardState,
      stoneCounts: stoneCounts,
      bonusActivatedBy: bonusResult.bonusActivated || [],
      rescueCardActivatedBy: collisions.flatMap((c) => c.losers),
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await db.collection("matches").doc(matchId).update({
      boardState: boardState,
      roundIndex: roundIndex + 1,
      currentPhase: "submitPhase",
    });

    const batch = db.batch();
    submissionsSnap.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    await batch.commit();

    console.log(`Round ${roundIndex} processed successfully`);
  } catch (error) {
    console.error("Error processing round:", error);
  }
});

/**
 * generateClip - Auto-generate match clip for sharing
 */
exports.generateClip = functions.https.onCall(async (data, context) => {
  const { matchId } = data;

  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  if (!matchId || typeof matchId !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "Invalid match ID");
  }

  try {
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Match not found");
    }

    const matchData = matchDoc.data();
    if (!matchData.players.includes(context.auth.uid)) {
      throw new functions.https.HttpsError("permission-denied", "User is not a player in this match");
    }

    const clipUrl = `https://storage.googleapis.com/toriverse-clips/${matchId}_clip.mp4`;

    await db.collection("matches").doc(matchId).collection("clips").doc("clip_0").set({
      matchId: matchId,
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      videoUrl: clipUrl,
      shareCount: 0,
    });

    return {
      clipUrl: clipUrl,
      success: true,
    };
  } catch (error) {
    console.error("Error generating clip:", error);
    throw new functions.https.HttpsError("internal", "Failed to generate clip");
  }
});

/**
 * finishMatch - Mark match as finished and calculate final standings
 */
exports.finishMatch = functions.https.onCall(async (data, context) => {
  const { matchId } = data;

  if (!matchId) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid match ID");
  }

  try {
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Match not found");
    }

    const matchData = matchDoc.data();
    const stoneCounts = countStones(matchData.boardState);

    await db.collection("matches").doc(matchId).update({
      status: "finished",
      finalScores: stoneCounts,
      finishedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    for (const playerId of matchData.players) {
      if (!playerId.startsWith("AI_")) {
        await db.collection("users").doc(playerId).update({
          completedMatchStreak: admin.firestore.FieldValue.increment(1),
        });
      }
    }

    return { success: true };
  } catch (error) {
    console.error("Error finishing match:", error);
    throw new functions.https.HttpsError("internal", "Failed to finish match");
  }
});

/**
 * Scheduled function: Reset daily free match quota at midnight UTC
 */
exports.resetDailyFreeMatches = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("UTC")
  .onRun(async (context) => {
    try {
      const usersRef = db.collection("users");
      const batch = db.batch();

      const snapshot = await usersRef.where("freeMatchUsedToday", ">", 0).get();

      snapshot.forEach((doc) => {
        batch.update(doc.ref, {
          freeMatchUsedToday: 0,
          lastDailyResetAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
      console.log(`Reset daily free matches for ${snapshot.size} users`);
    } catch (error) {
      console.error("Error resetting daily free matches:", error);
    }
  });
