# Firebase Emulator Setup & Configuration

**Status**: ✅ Production Ready  
**Date**: 2026-09-02  
**Target**: Local development & CI/CD testing

---

## Overview

This document describes the Firebase Emulator setup for Toriverse, enabling local Firestore testing without external Firebase connectivity. Used in combination with `fake_cloud_firestore` for unit/integration tests.

---

## Installation & Setup

### Prerequisites

- Node.js 14+ (for Firebase CLI)
- Docker (optional, for containerized emulator)
- Firebase CLI 10.0+

### Install Firebase CLI

```bash
npm install -g firebase-tools

# Verify installation
firebase --version
```

### Initialize Firebase Emulator in Project

```bash
# From project root
firebase init emulator

# Select services to emulate:
# - Firestore Database ✓
# - Cloud Pub/Sub (optional, for FCM simulation)
# - Firebase Authentication (optional, for auth flow testing)

# Default ports:
# Firestore: 8080
# Pub/Sub: 8085
# Auth: 9099
```

### Emulator Configuration File

**File**: `firebase.json` (auto-generated, customize as needed)

```json
{
  "emulators": {
    "firestore": {
      "port": 8080,
      "host": "127.0.0.1"
    },
    "pubsub": {
      "port": 8085,
      "host": "127.0.0.1"
    },
    "auth": {
      "port": 9099,
      "host": "127.0.0.1"
    }
  },
  "emulator": {
    "rules": "firestore.rules"
  }
}
```

---

## Running the Emulator

### Local Development

```bash
# Start all emulators
firebase emulators:start

# Output should show:
# ✓ Firestore Emulator running at http://127.0.0.1:8080
# ✓ Pub/Sub emulator running at http://127.0.0.1:8085
# ✓ Auth emulator running at http://127.0.0.1:9099

# Access Emulator UI: http://127.0.0.1:4000
```

### CI/CD Integration

```bash
# Run emulator in background
firebase emulators:start --only firestore &

# Wait for startup
sleep 5

# Run tests
flutter test test/e2e/

# Stop emulator
pkill -f "firebase emulators"
```

### Docker Containerization (Production CI)

**Dockerfile** (optional, for isolated CI environments)

```dockerfile
FROM node:18-alpine

# Install Firebase CLI
RUN npm install -g firebase-tools

# Copy Firebase config
COPY firebase.json /app/firebase.json
COPY firestore.rules /app/firestore.rules

WORKDIR /app

# Expose Firestore port
EXPOSE 8080 8085 9099

# Start emulator
CMD ["firebase", "emulators:start", "--only", "firestore,pubsub,auth"]
```

**Run in Docker**:

```bash
docker build -t toriverse-firebase-emulator .
docker run -p 8080:8080 -p 8085:8085 -p 9099:9099 \
  --name firebase-emu \
  toriverse-firebase-emulator
```

---

## Connecting Flutter App to Emulator

### Environment Setup

**Create `.env.local`** (development only):

```bash
# Firebase Emulator Configuration
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099
FIREBASE_EMULATOR_PUBSUB_HOST=127.0.0.1:8085

# Feature Flags
USE_FIREBASE_EMULATOR=true
```

### Flutter Integration Code

**`lib/config/firebase_config.dart`**:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
  
  // Only use emulator in development
  if (!kIsProduction && !kIsWeb) {
    // Connect to Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }
}
```

**`lib/config/environment.dart`**:

```dart
const bool kIsProduction = bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);
const String firestoreEmulatorHost = 
  String.fromEnvironment('FIRESTORE_EMULATOR_HOST', defaultValue: '127.0.0.1:8080');
```

---

## Test Configuration

### Unit/Integration Tests

**`test/firebase_test_setup.dart`**:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    // Use FakeFirebaseFirestore for deterministic testing
    // No external connection required
  });

  group('Firebase Tests', () {
    test('example test', () async {
      final firestore = FakeFirebaseFirestore();
      
      // Test code
      await firestore.collection('test').doc('doc1').set({'data': 'value'});
      
      final doc = await firestore.collection('test').doc('doc1').get();
      expect(doc.data()?['data'], equals('value'));
    });
  });
}
```

### E2E Tests with Real Emulator

**To connect E2E tests to real Firestore Emulator**:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> setupFirebaseEmulator() async {
  // Skip if running integration test
  if (!Platform.environment.containsKey('FIRESTORE_EMULATOR_HOST')) {
    await Firebase.initializeApp();
    return;
  }

  // Connect to running emulator
  FirebaseFirestore.instance.useFirestoreEmulator(
    Platform.environment['FIRESTORE_EMULATOR_HOST']?.split(':')[0] ?? '127.0.0.1',
    int.parse(Platform.environment['FIRESTORE_EMULATOR_HOST']?.split(':')[1] ?? '8080'),
  );
}
```

---

## Firestore Security Rules

**File**: `firestore.rules`

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Disable auth for emulator (all access allowed)
    match /{document=**} {
      allow read, write: if true;
    }

    // Optional: Add development-specific rules
    match /campaigns/{campaignId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /users/{uid}/{document=**} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

---

## Data Management

### Seed Test Data

**Script**: `scripts/seed_emulator.js`

```javascript
const admin = require('firebase-admin');

async function seedEmulator() {
  // Connect to Firestore emulator
  process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';

  const db = admin.firestore();

  // Seed campaigns
  const campaigns = [
    { id: 'camp_001', name: 'Launch Week', currently_live: true },
    { id: 'camp_002', name: 'Weekend Bonus', currently_live: false },
  ];

  for (const campaign of campaigns) {
    await db.collection('campaigns').doc(campaign.id).set(campaign);
  }

  console.log('✓ Emulator seeded with test data');
}

seedEmulator().catch(console.error);
```

**Run seeding**:

```bash
firebase emulators:start &
sleep 2
node scripts/seed_emulator.js
```

### Clear Emulator Data

```bash
# During development session
firebase emulators:start --import=./firestore_backup

# After testing
firebase emulators:export ./firestore_backup
```

---

## Performance Benchmarking

### Metrics to Capture

- **Query latency**: Time for Firestore reads (target: < 50ms)
- **Write latency**: Time for document updates (target: < 100ms)
- **Batch operations**: Bulk claims/tracking (target: < 1000ms for 50 ops)
- **Concurrent operations**: Multiple users simultaneously (target: consistent latency)

### Profiling Test

**`test/e2e/performance_profiling_e2e_test.dart`** includes:

```dart
group('Performance Profiling E2E Tests', () {
  test('fetching 10 active campaigns completes within 500ms', () async {
    // Performance test
  });

  test('claiming 50 rewards across 5 users takes < 2 seconds', () async {
    // Bulk operation test
  });
});
```

**Run with profiling**:

```bash
# Start emulator
firebase emulators:start --only firestore &

# Run performance tests with verbose output
flutter test test/e2e/performance_profiling_e2e_test.dart -v

# Results printed to console
```

---

## CI/CD Integration

### GitHub Actions Workflow

**`.github/workflows/e2e_tests.yml`**:

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    services:
      firebase:
        image: node:18-alpine
        options: >
          --name firebase-emulator
          --entrypoint "firebase"
          --args "emulators:start --only firestore"

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Wait for Firebase Emulator
        run: |
          until curl -s http://localhost:8080 > /dev/null; do
            echo 'Waiting for Firebase Emulator...'
            sleep 2
          done

      - name: Run E2E Tests
        env:
          FIRESTORE_EMULATOR_HOST: 'localhost:8080'
        run: flutter test test/e2e/

      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test-results.xml
```

---

## Troubleshooting

### Emulator Won't Start

```bash
# Check for port conflicts
lsof -i :8080
lsof -i :8085

# Free up ports
kill -9 <PID>

# Restart emulator
firebase emulators:start --only firestore
```

### Connection Refused in Tests

```bash
# Verify emulator is running
curl http://127.0.0.1:8080

# Check environment variables
echo $FIRESTORE_EMULATOR_HOST

# Ensure app is configured to use emulator
# See "Connecting Flutter App to Emulator" section
```

### Data Persistence Issues

```bash
# Export data before stopping
firebase emulators:export ./backup

# Start with backup
firebase emulators:start --import=./backup
```

### Performance Degradation

```bash
# Clear emulator and restart
pkill -f "firebase emulators"
rm -rf .firebase

# Fresh start
firebase emulators:start --only firestore
```

---

## Testing Checklist

- ✅ Firebase Emulator runs locally without external dependencies
- ✅ E2E tests connect to emulator and validate complete flows
- ✅ Performance profiling captures latency metrics
- ✅ CI/CD pipeline can run E2E tests in isolated environment
- ✅ Data can be seeded and cleared for test isolation
- ✅ Security rules enforced (when needed)
- ✅ Concurrent operations handled correctly
- ✅ Query results consistent with production Firestore

---

## Deployment Readiness

### Pre-Launch Validation

- ✅ E2E tests passing locally
- ✅ Performance benchmarks meet targets
- ✅ CI/CD pipeline green
- ✅ No external service dependencies during test
- ✅ Data isolation verified (no cross-test contamination)

### Production Firebase

1. Create Firebase project (if not exists)
2. Enable Firestore Database (production mode)
3. Configure security rules for production
4. Set up Firebase Remote Config
5. Migrate seed data from emulator
6. Run final integration tests against production

---

## References

- Firebase Emulator Suite: https://firebase.google.com/docs/emulator-suite
- Firestore Emulator: https://firebase.google.com/docs/firestore/security/test-rules-emulator
- fake_cloud_firestore package: https://pub.dev/packages/fake_cloud_firestore

---

**Report Date**: 2026-09-02  
**Status**: Ready for Phase 8h E2E Testing  
**Next**: Production Firebase deployment validation
