# design-patterns

GoF patterns are named forces, not recipes. Earn a pattern from forces, then map it to craft.

## Earn this branch

User names a GoF pattern / asks which fits, or forces match: creation flexibility, decoupled notification, pluggable behavior, undo/history.

## Forces → pattern → co-load

- Creator must not hard-code concretes → Factory Method / Abstract Factory (families); stepwise multi-representation build → Builder.
- Expensive/variant-rich construction → Prototype; shared fine-grained state → Flyweight — both `performance`, measure first.
- Singleton: almost never earned — an uninjectable global unless construction stays explicit and testable (`deep-modules`).
- Wrap/narrow a foreign or subsystem interface → Adapter / Facade / Proxy (`refactor-boundaries`).
- Vary abstraction vs implementation, part-whole trees, add responsibilities, replace a colleague mesh → Bridge / Composite / Decorator / Mediator (`deep-modules`).
- Behavior varies by internal state or call-site-selected algorithm → State / Strategy (`refactor-types` — often a closed set suffices).
- Queue/undo/log requests → Command; restore state → Memento; decoupled notification → Observer; handler chain → Chain of Responsibility.

## Guardrails

- Forces first, name second — no pattern-shopping.
- Any new pattern layer must pass the deletion test; forwarding-only ceremony is a shallow module.
- Idiomatic realizations belong in `{lang}-dev` / overlays / project `AGENTS.md`.

## Done when

Pattern choice justified by named forces, or rejected; deletion test upheld on any new layer; co-load branch named when structure / type / boundary / perf work follows.
