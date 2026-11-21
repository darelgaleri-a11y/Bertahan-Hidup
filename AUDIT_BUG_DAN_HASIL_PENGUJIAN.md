# Audit Bug & Stability Update — v7

## Repository inspected
- https://github.com/darelgaleri-a11y/Bertahan-Hidup
- Branch: main
- Source tree inspected before creating this patch.

## Fixes in this update
1. Monster respawn no longer waits indefinitely on a region-change signal. A due respawn is queued and spawned when its home region becomes active.
2. Respawn placement is performed through a single helper, with signal hookup before the node enters the SceneTree.
3. Player defeat recovery uses the current exploration region spawn, not a property-land spawn.
4. NPC scenes explicitly declare their home region as village, avoiding reliance on an implicit script default.
5. Monster Job Level gates now match the region progression: Skeleton requires Job Level 3; Elite Beast requires Job Level 5.

## Static checks
- JSON catalog parse and resource path checks were run for this patch.
- Scene resource counts and NPC/monster region-level declarations were checked.
- ZIP archive integrity was checked.

## Not verified
Godot Engine was not available in this environment. GDScript parsing inside Godot, scene runtime, gameplay, and Android builds must still be tested in Godot Editor/device.
