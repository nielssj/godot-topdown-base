# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Engine & Runtime

- **Godot 4.4** project using GDScript
- Rendering: GL Compatibility (mobile-friendly)
- Run the game: open the project in the Godot editor and press F5, or use `godot --path . scenes/main.tscn` from the CLI
- No build step required — GDScript is interpreted at runtime

## Project Architecture

This is a 3D top-down game. The main scene (`main.tscn`) composes the game by instancing a level and the player into a shared environment.

**Scene hierarchy:**
```
main.tscn (entry point)
├── Common/          — common objects light, camera etc
├── Level           — instance of levels/*.tscn
└── Player           — instance of entities/characters/Player.tscn
```

**Key directories:**
- `entities/characters/` — Characters including both NPC and PC
- `levels/` — Levels containing unique compositions of environment meshes, colliders and spawn positions for characters
