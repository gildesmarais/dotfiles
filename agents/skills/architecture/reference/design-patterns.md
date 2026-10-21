# design-patterns

GoF patterns are named forces, not recipes. Earn a pattern from forces, then map it to craft.

## Earn this branch

User names a GoF pattern / asks which fits, or forces match: creation flexibility, decoupled notification, pluggable behavior, undo/history.

## Forces → co-load

- Creation flexibility / families / stepwise build → Factory / Abstract Factory / Builder; expensive construction → Prototype (+ `performance`).
- Shared fine-grained state → Flyweight (+ `performance`). Singleton: almost never — uninjectable global unless construction stays explicit (`deep-modules`).
- Wrap/narrow foreign interface → Adapter / Facade / Proxy (`refactor-boundaries`).
- Abstraction vs implementation, part-whole, responsibilities, colleague mesh → Bridge / Composite / Decorator / Mediator (`deep-modules`).
- Behavior by state or call-site algorithm → State / Strategy (`refactor-types`).
- Queue/undo/log → Command; restore → Memento; notification → Observer; handler chain → Chain of Responsibility.

## Guardrails

- Forces first, name second — no pattern-shopping.
- New pattern layer must pass the deletion test; forwarding-only ceremony is a shallow module.
- Idiomatic realizations belong in `{lang}-dev` / overlays / project `AGENTS.md`.

## Done when

Pattern choice justified by named forces, or rejected; deletion test upheld; co-load branch named when structure / type / boundary / perf work follows.
