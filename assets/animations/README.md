# Animation Assets (Lottie JSON)

This directory contains Lottie animation JSON files for the Toriverse game. These animations are played during critical game moments to enhance player engagement.

## Animation Files Required

### 1. `weak_bonus.json` (弱者ボーナス)
**Purpose**: Played when a player activates weak bonus  
**Duration**: 1.5-2 seconds  
**Visual Elements**:
- Star burst effect (黄色 / Yellow)
- Upward motion to convey "boost/advantage"
- Player stone color highlight
- Text: "弱者ボーナス発動"

**Triggers in Game**:
- Remaining rounds ≤ 11
- Stone difference ≥ 8 (bottom 20%)
- Max 2 activations per match

**Reference**: `/lib/features/match/presentation/widgets/animations/weak_bonus_animation_widget.dart`

---

### 2. `rescue_card.json` (救済カード)
**Purpose**: Played when a player receives a rescue card  
**Duration**: 1.5-2 seconds  
**Visual Elements**:
- Card flip/reveal effect (赤 / Red)
- Gift box or card icon animation
- Player stone color highlight
- Text: "救済カード獲得"

**Triggers in Game**:
- Consecutive attacks from same opponent ≥ 2 rounds
- Collision resolution (lost the random draw)

**Reference**: `/lib/features/match/presentation/widgets/animations/rescue_card_animation_widget.dart`

---

### 3. `collision_resolution.json` (同マス被り)
**Purpose**: Played when multiple players place on same square  
**Duration**: 2-2.5 seconds  
**Visual Elements**:
- Clash/collision effect (紫 / Purple)
- Winner spotlight or checkmark
- Loser highlight (for rescue card award notification)
- Board square coordinates

**Triggers in Game**:
- 2+ players submit the same board position
- Random winner determined
- Losers receive rescue card

**Reference**: `/lib/features/match/presentation/widgets/animations/collision_resolution_animation_widget.dart`

---

### 4. `lottery.json` (くじ引き - Lottery Drawing)
**Purpose**: Played during process order randomization  
**Duration**: 2.5-3 seconds  
**Visual Elements**:
- Spinning/rolling dice or lottery machine effect
- Suspenseful anticipation motion
- Gradual reveal of process order (1番目, 2番目, 3番目)
- Slot machine "reveal" feeling

**Triggers in Game**:
- After all players submit moves
- Before moves are processed and stones are flipped
- Reveals the order in which moves will be processed

**Reference**: `/lib/features/match/presentation/widgets/animations/lottery_animation_widget.dart`

---

## Technical Specifications

### File Format
- **Format**: Lottie JSON (exported from Lottie/After Effects)
- **Compatibility**: Lottie 2.6.0+
- **Color Scheme**: Respect Toriverse theme colors:
  - Black stone (0): `#000000`
  - White stone (1): `#FFFFFF`
  - Red stone (2): `#FF4444`
  - Accent: `#FF6B6B`

### Animation Playback
All animations are auto-playing, non-looping sequences integrated via:
```dart
import 'package:lottie/lottie.dart';
Lottie.asset('assets/animations/weak_bonus.json', ...)
```

### Placeholder Implementation
Currently, each animation widget uses a **placeholder Flutter icon animation**:
- WeakBonusAnimationWidget: `Icons.stars` (yellow)
- RescueCardAnimationWidget: `Icons.card_giftcard` (red)
- CollisionResolutionAnimationWidget: `Icons.blur_on` (purple)
- LotteryAnimationWidget: `Icons.casino` (amber, rotating)

When actual Lottie JSON files are added, replace the `_buildLottieAnimation()` methods in each widget with:

```dart
Widget _buildLottieAnimation() {
  return Lottie.asset(
    'assets/animations/weak_bonus.json',
    width: 160,
    height: 160,
    fit: BoxFit.contain,
  );
}
```

---

## Asset Creation Guide

### For Designers
1. **Design in After Effects** or **Lottie Files** (lottie.com)
2. **Export to Lottie JSON**:
   - File → Export → Lottie JSON
   - Ensure frame rate: 30 FPS
   - Set duration as specified above
   - Test in Lottie preview before export

3. **Naming Convention**:
   - kebab-case (e.g., `weak_bonus.json`)
   - No spaces, special characters except hyphens

4. **File Size**:
   - Target: < 50 KB per animation
   - Use shape layers, minimal rasterization
   - Optimize curves and keyframes

### For Developers
- Place exported JSON in `assets/animations/`
- Update `pubspec.yaml` if needed to register assets
- Test on iOS/Android emulators for performance
- Verify frame rate consistency across devices

---

## Future Enhancements

### Phase 13.5 (Post-MVP)
- [ ] Add camera shake effect to collision animations
- [ ] Add particle effects for bonus activation
- [ ] Add sound effects synchronized with animations
- [ ] Add haptic feedback on Android/iOS

### Phase 2 (Live Viewing)
- [ ] Optimize animations for 60 FPS on lower-end devices
- [ ] Add animation quality settings (high/medium/low)
- [ ] Stream animation sequences to live viewers

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Animation not playing | Check file path in `Lottie.asset()`, ensure file exists |
| Animation stuttering | Reduce animation complexity, check device performance |
| Colors not matching | Verify JSON color values match `theme.dart` definitions |
| Performance issues | Profile with Flutter DevTools, optimize JSON complexity |

---

**Last Updated**: 2026-09-11  
**Maintained By**: Claude / Phase 13 Implementation
