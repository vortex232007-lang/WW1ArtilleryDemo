# WW1 Artillery Demo (Swift)

A command-line prototype for **Quantum Entertainment**.

## What this demo includes
- Choose a side: **German** or **British**.
- Nation color mapping: **British = Blue (🔵)**, **German = Red (🔴)**.
- Choose a battlefield map: **Snow**, **Rainy** (brown + rain overlay), or **Green**.
- Wave system with the required progression:
  - Wave 1: 5 enemies
  - Wave 2: 10 enemies
  - Wave 3: 15 enemies
  - Wave 4: 20 enemies
  - Wave 5: 25 enemies
- “Observe and prepare guns” phase before each wave:
  - Set aim X coordinate
  - Set spread (accuracy)
  - Set shells per salvo
- A **READY** prompt before each wave starts.
- Enemy units spawn from trench line and advance through No Man’s Land.
- If enemies breach too deep into NML, pressure increases and you can lose early.

## Run
```bash
swift run
```

## Notes
This is a gameplay prototype focused on loop and pacing logic. It is intentionally lightweight so it can be used as a pitching/demo baseline and then upgraded to a full SpriteKit/SwiftUI visual build later.
