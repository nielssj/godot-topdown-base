# State Machine Pattern

The pattern is a setter-driven finite state machine built around a single state variable. Three things happen on every transition, in order:

 1. Exit hook runs against the old state (matched before assignment)
 1. Assignment of the new state value
 1. Enter hook runs against the new state (matched after assignment)

Per-frame behavior is dispatched separately in _physics_process via a match on the current state, calling a per-state tick function.

## Why this shape works

Transitions are atomic: setting state = NEW triggers exit + enter in one place. Callers never have to remember the bookkeeping.

Hooks are split by lifecycle: _enter_X for one-shot setup (timers, target selection, visuals), _exit_X for cleanup (hide UI, release resources), _X for per-frame logic.

Self-transitions are guarded: the if state != value check around the exit match prevents re-entering a state from firing exit/enter when the value didn't actually change.

Cross-cutting checks live outside the match: things like stuck detection run every frame regardless of state, with the state-specific function deciding whether the check is even meaningful.

State changes can be triggered from anywhere: a tick function, an enter hook, an external signal handler — they all go through the same setter.

## Generic snippet

```
class_name GenericStateMachineEntity
extends Node  # or CharacterBody3D, etc.

enum EntityState {
    STATE_A,
    STATE_B,
    STATE_C
}

var active: bool = false

var state: EntityState = EntityState.STATE_A:
    set(value):
        # Exit functions (match on OLD state, before assignment)
        if state != value:
            match state:
                EntityState.STATE_A:
                    _exit_state_a()
                EntityState.STATE_B:
                    pass  # no cleanup needed
                EntityState.STATE_C:
                    _exit_state_c()

        # Assign new state
        state = value
        print("Entity state: ", state)

        # Enter functions (match on NEW state, after assignment)
        match state:
            EntityState.STATE_A:
                _enter_state_a()
            EntityState.STATE_B:
                _enter_state_b()
            EntityState.STATE_C:
                _enter_state_c()

func activate() -> void:
    active = true
    # Kick off the state machine by firing the initial enter hook
    _enter_state_a()

func _physics_process(_delta: float) -> void:
    if not active:
        return

    # Per-frame dispatch — each state has its own tick function
    match state:
        EntityState.STATE_A:
            _tick_state_a()
        EntityState.STATE_B:
            _tick_state_b()
        EntityState.STATE_C:
            _tick_state_c()

# --- Enter hooks: one-shot setup when entering a state ---
func _enter_state_a() -> void:
    pass  # e.g. pick a target, reset a timer, show UI

func _enter_state_b() -> void:
    pass

func _enter_state_c() -> void:
    pass

# --- Exit hooks: cleanup when leaving a state (only define if needed) ---
func _exit_state_a() -> void:
    pass  # e.g. hide UI, release a lock

func _exit_state_c() -> void:
    pass

# --- Tick functions: per-frame logic; transition by assigning `state = ...` ---
func _tick_state_a() -> void:
    if _some_condition():
        state = EntityState.STATE_B  # triggers exit_a + enter_b automatically

func _tick_state_b() -> void:
    pass

func _tick_state_c() -> void:
    pass

func _some_condition() -> bool:
    return false
```

## Conventions worth keeping

 - Name enter/exit/tick functions consistently (_enter_x, _exit_x, _x or _tick_x) so the dispatch tables stay scannable.
 - pass # not needed, yet placeholders in the exit match (as in customer.gd:35-42) document that you considered the state and decided no cleanup was needed — better than omitting branches.
 - Always transition by writing state = NEW rather than calling _enter_x() directly, so exit hooks aren't skipped. The one exception is the initial kickoff in activate(), where there's no prior state to exit.
 - Keep enter hooks idempotent enough that re-entry from recovery paths (like customer.gd:392) is safe.

## Limitations
 - No transition guards — any state can move to any other state. If you need to reject illegal transitions, add a validation step in the setter.
 - No history/stack — can't "return to previous state" without tracking it manually.
 - Scales poorly past ~6-8 states; at that point a state-object pattern (each state as its own class) reads better