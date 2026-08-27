# Performance & Load Testing Guide

**Purpose**: Ensure app performance meets SLAs before soft launch  
**Target**: Sub-2s app startup, smooth 60 FPS gameplay  
**Timeline**: Complete 1 week before launch

---

## 1. Local Performance Testing

### 1.1 App Startup Time

```bash
# Measure app startup on release build
flutter run --release

# Monitor Logcat (Android):
adb logcat | grep "ActivityManagerService"
# Look for: "Displayed com.zkaz.toriverse / <time>ms"

# Monitor Console (iOS):
# Xcode → Debug → Console
# Look for: "[ViewService] Finished after Xs"
```

**Target**: < 2000ms (2 seconds)

### 1.2 Frame Rate Analysis

Install DevTools:

```bash
flutter pub global activate devtools
devtools
```

In DevTools:

1. Run app on device
2. Go to Performance tab
3. Record for 30 seconds during gameplay
4. Analyze frames:
   - Target: 60 FPS (16.67ms per frame)
   - Alert: < 50 FPS (jank visible)
   - Critical: < 30 FPS (game unplayable)

### 1.3 Memory Profiling

In DevTools → Memory tab:

```
Monitor during:
1. App startup: Should stabilize < 150MB
2. Board rendering: Should not exceed 200MB
3. After 10 matches: Should be stable (no memory leak)
```

### 1.4 CPU Usage

Measure with Xcode/Android Studio:

```
Threshold:
- Normal UI: < 20% CPU
- During move processing: Peak 40%
- Idle: < 5% CPU
```

---

## 2. Firebase Performance Monitoring

### 2.1 Enable Firebase Performance

In `lib/main.dart`:

```dart
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable performance monitoring
  FirebasePerformance.instance.isPerformanceCollectionEnabled = true;
  
  runApp(const App());
}
```

### 2.2 Create Custom Traces

```dart
class GameStateNotifier {
  Future<void> placeStone(int row, int col) async {
    // Create trace
    final trace = FirebasePerformance.instance.newTrace('place_stone');
    await trace.start();

    try {
      // Your move placement logic
      // ...
      trace.putAttribute('row', row.toString());
      trace.putAttribute('col', col.toString());
    } finally {
      await trace.stop();
    }
  }
}
```

### 2.3 Custom Metrics

```dart
// Track custom metrics
await trace.setMetric('flipCount', flippedStones.length);
await trace.setMetric('processingTime', duration.inMilliseconds);
```

---

## 3. Load Testing

### 3.1 Firestore Load Testing

Use Firebase Load Testing tool:

```bash
# Create load test configuration
cat > load_test.json << 'EOF'
{
  "config": {
    "projectId": "toriverse-prod",
    "duration": "600s",
    "overallQPS": 100,
    "operations": [
      {
        "type": "READ",
        "path": "matches/{match_id}",
        "rate": 50
      },
      {
        "type": "WRITE",
        "path": "roundResults/{round_id}",
        "rate": 40
      },
      {
        "type": "READ",
        "path": "users/{user_id}",
        "rate": 10
      }
    ]
  }
}
EOF

# Run test (requires Firebase CLI)
firebase firestore:run-load-test load_test.json
```

### 3.2 Cloud Functions Load Testing

Use Apache JMeter:

```bash
# Install JMeter
brew install jmeter  # macOS
# or download from https://jmeter.apache.org/

# Create test plan:
# 1. Thread Group: 100 threads
# 2. HTTP Sampler: POST to submitMove endpoint
# 3. Ramp-up: 60 seconds
# 4. Duration: 10 minutes
# 5. Assertions: Response time < 500ms, error rate < 1%

# Run test
jmeter -n -t move_submission_test.jmx -l results.jtl -j jmeter.log
```

**Target**: 
- Latency: < 500ms p99
- Error rate: < 0.1%
- Throughput: > 100 requests/second

### 3.3 Matchmaking Load Test

Simulate concurrent players:

```dart
// test/integration/load_test_matching.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/matching_state.dart';

void main() {
  test('Concurrent matching simulation', () async {
    final container = ProviderContainer();
    
    // Simulate 100 concurrent match requests
    final futures = List.generate(100, (i) {
      return Future(() {
        container.read(matchingStateProvider.notifier).startMatching();
      });
    });

    final stopwatch = Stopwatch()..start();
    await Future.wait(futures);
    stopwatch.stop();

    final matchingState = container.read(matchingStateProvider)!;
    expect(matchingState.playerCount, 3);
    expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // < 5s for all
  });
}
```

---

## 4. Stress Testing

### 4.1 Memory Stress

```dart
// Force multiple board state changes
void stressTestBoardMemory() {
  final container = ProviderContainer();
  
  for (int i = 0; i < 1000; i++) {
    container.read(gameStateProvider.notifier).startGame(
      playerIds: ['player_0', 'player_1', 'AI_1'],
    );
    
    // Make moves
    final state = container.read(gameStateProvider)!;
    if (state.validMoves.isNotEmpty) {
      final move = state.validMoves.first;
      container.read(gameStateProvider.notifier)
        .placeStone(move.row, move.col);
    }
    
    container.read(gameStateProvider.notifier).resetGame();
  }
  
  // Memory should not leak
  // Final memory should be < 1.5x initial
}
```

### 4.2 Firestore Connection Stress

```bash
# Simulate network interruptions
# Using Charles Proxy or Fiddler:

1. Set throttle: 1Mbps down, 0.5Mbps up (poor 3G)
2. Add latency: +500ms
3. Add packet loss: 5%
4. Run game flow test
5. Verify app recovers gracefully
```

### 4.3 Battery Drain Test

On device:

```bash
# iOS (Xcode)
1. Product → Scheme → Edit Scheme
2. Run → Options → GPU Frame Capture
3. Play game for 5 minutes
4. Check battery usage (Settings → Battery)

# Android (Logcat)
adb shell dumpsys batterystats | grep POWER
# Should show < 5% drain per hour during idle
```

---

## 5. Network Condition Testing

### 5.1 Network Throttling (Local)

**Using Android Emulator:**

```bash
# Slow 3G
adb shell sysctl -w net.ipv4.tcp_wmem="4096 65536 524288"
adb shell sysctl -w net.ipv4.tcp_rmem="4096 65536 524288"

# Or use emulator settings:
# Settings → Network → Speed: EDGE, 3G, LTE
```

**Using iOS Simulator:**

```bash
# Xcode → Debug → Simulate Location/Network Link Conditioner
# Or install Network Link Conditioner:
# https://developer.apple.com/download/all/
```

### 5.2 Offline Mode Testing

Simulate disconnection:

```bash
# Android
adb shell cmd connectivity airplane-mode enable
# Then: adb shell cmd connectivity airplane-mode disable

# iOS
Settings → Airplane Mode → On/Off
```

Test offline flow:
- [ ] App doesn't crash
- [ ] Offline UI appears
- [ ] Queued moves saved locally
- [ ] Auto-reconnect when network returns
- [ ] Moves synced to server

### 5.3 High Latency Testing

Using VPN or proxy:

```bash
# Add 500ms latency
# Monitor behavior:
# - Timeout handling (should be 10s)
# - User feedback (loading indicator)
# - Retry logic (exponential backoff)
```

---

## 6. Battery & Power Testing

### 6.1 Power Profiler (Android Studio)

```
Android Studio → Profiler → Power
Monitor during:
1. Idle state: Should be minimal
2. Board rendering: Should show ~40mW
3. Network activity: Should show spike
```

### 6.2 Energy Impact (Xcode)

```
Xcode → Debug → Energy Impact
Target: Low energy impact (< 20 on scale of 0-100)
```

### 6.3 Battery Life Simulation

```bash
# Run game for 1 hour on single charge
# Expected battery drain: 10-15%
# (Acceptable for gaming app)
```

---

## 7. Accessibility Testing

### 7.1 Screen Reader (iOS)

Enable VoiceOver:
```
Settings → Accessibility → VoiceOver → On
```

Test:
- [ ] All buttons labeled
- [ ] Board squares are readable
- [ ] Score display is audible
- [ ] Game progress announcements

### 7.2 Screen Reader (Android)

Enable TalkBack:
```
Settings → Accessibility → TalkBack → On
```

Test same as iOS.

### 7.3 Text Size

Test with large text:
```
Settings → Text Size → Large
```

- [ ] UI doesn't overflow
- [ ] All text readable
- [ ] Buttons still tappable (44pt minimum)

### 7.4 Color Contrast

Verify WCAG AA compliance (minimum 4.5:1 contrast ratio):
- [ ] Black stones on white background
- [ ] White stones on board
- [ ] Text on background
- [ ] Buttons on background

---

## 8. Localization Testing (Japanese)

### 8.1 Japanese Text Rendering

```dart
// Verify Japanese renders correctly
final japaneseText = "トリバース - 3色オセロ";
expect(japaneseText.length, 12);
```

Test on device:
- [ ] Japanese characters display correctly
- [ ] No text overflow
- [ ] Proper line breaking
- [ ] Font rendering quality

### 8.2 Date/Time Formatting

```dart
// Verify Japanese date format
final formatter = DateFormat('yyyy年M月d日');
expect(formatter.format(DateTime(2026, 8, 27)), '2026年8月27日');
```

### 8.3 Number Formatting

```dart
// Verify Japanese number format
final formatter = NumberFormat('#,##0', 'ja_JP');
expect(formatter.format(1234567), '1,234,567');
```

---

## 9. Test Results Template

Create file: **`PERFORMANCE_TEST_RESULTS.md`**

```markdown
# Performance Test Results - Phase 7

**Test Date**: 2026-08-27  
**Tester**: _______  
**Device**: _______ (Model, OS version)  
**Network**: WiFi / 4G / 3G

## Startup Performance
- Cold start: ___ms (Target: < 2000ms) ✓/✗
- Warm start: ___ms (Target: < 1000ms) ✓/✗
- Board rendering: ___ms (Target: < 500ms) ✓/✗

## Runtime Performance
- Average FPS: ___ (Target: 60) ✓/✗
- Minimum FPS: ___ (Alert if < 50)
- Jank count: ___ (Target: 0)

## Memory Usage
- Startup: ___MB (Target: < 150MB) ✓/✗
- Peak: ___MB (Alert if > 300MB)
- After 10 matches: ___MB (Should be stable)

## Firebase Performance
- Read latency p99: ___ms (Target: < 100ms) ✓/✗
- Write latency p99: ___ms (Target: < 200ms) ✓/✗
- Error rate: __% (Target: < 0.1%) ✓/✗

## Network Resilience
- Offline handling: ✓/✗
- Reconnection latency: ___s (Target: < 5s)
- Move sync consistency: ✓/✗

## Issues Found
- [ ] None
- [ ] Issue 1: __________
- [ ] Issue 2: __________

## Sign-Off
Performance acceptable for launch: ✓/✗
```

---

## 10. Pre-Launch Performance Checklist

- [ ] App startup < 2 seconds on 4G
- [ ] 60 FPS during board interaction
- [ ] Memory stable after 10 matches
- [ ] No memory leaks detected
- [ ] Firebase latency < 100ms p99
- [ ] Offline mode works
- [ ] Reconnection smooth
- [ ] Battery drain acceptable (< 15%/hour)
- [ ] Japanese text renders correctly
- [ ] All accessibility features work
- [ ] Network throttling handled gracefully
- [ ] All performance tests passed

---

**Status**: ✅ Performance Testing Framework Ready  
**Created**: 2026-08-27
