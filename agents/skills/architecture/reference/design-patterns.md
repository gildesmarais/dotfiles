# design-patterns

GoF patterns as named forces — not implementation recipes. A pattern must be earned; pattern ceremony that fails the deletion test is a shallow module.

## Earn this branch

The user names a GoF pattern, asks which pattern fits, or forces match: object-creation flexibility, decoupled notification, pluggable behavior, undo/history.

## Patterns

| Pattern                 | Intent + earning force                                                                              | Co-load                       |
| ----------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------- |
| _Creational_            |                                                                                                     |                               |
| Factory Method          | Subclass decides which product to instantiate when the creator must not hard-code the concrete type | —                             |
| Abstract Factory        | Families of related products must be created together without naming concretes                      | —                             |
| Builder                 | Construct a complex object stepwise when many representations share the same construction process   | —                             |
| Prototype               | Clone an existing instance when construction is expensive or variant-rich                           | `performance` (measure first) |
| Singleton               | One instance with a global access point — almost never earned; prefer explicit construction homes   | `deep-modules`                |
| _Structural_            |                                                                                                     |                               |
| Adapter                 | Make an existing interface usable by wrapping it at a boundary                                      | `refactor-boundaries`         |
| Bridge                  | Split abstraction from implementation so they vary independently                                    | `deep-modules`                |
| Composite               | Treat part-whole trees uniformly                                                                    | `deep-modules`                |
| Decorator               | Add responsibilities by wrapping without subclass explosion                                         | `deep-modules`                |
| Facade                  | Narrow a subsystem behind a single interface                                                        | `refactor-boundaries`         |
| Flyweight               | Share fine-grained state to cut identity/alloc traffic                                              | `performance` (measure first) |
| Proxy                   | Stand-in that controls access, lazy load, or remote                                                 | `refactor-boundaries`         |
| _Behavioral_            |                                                                                                     |                               |
| Chain of Responsibility | Pass a request along handlers until one handles it                                                  | —                             |
| Command                 | Encapsulate a request as an object (queue, undo, log)                                               | —                             |
| Iterator                | Access aggregate elements without exposing representation                                           | —                             |
| Mediator                | Colleagues communicate through one object instead of a mesh                                         | `deep-modules`                |
| Memento                 | Capture and restore internal state without violating encapsulation                                  | —                             |
| Observer                | Notify dependents of state changes without coupling sender to receivers                             | —                             |
| State                   | Object alters behavior when its internal state changes                                              | `refactor-types`              |
| Strategy                | Family of interchangeable algorithms selected at the call site                                      | `refactor-types`              |
| Template Method         | Skeleton algorithm in a base; steps vary in subclasses                                              | —                             |
| Visitor                 | Add operations over an object structure without changing the elements                               | —                             |

## Guardrails

- Forces first, name second — do not pattern-shop.
- Any new pattern layer must pass the deletion test; ceremony that only forwards is a shallow module.
- Singleton is an uninjectable global store unless construction is still explicit and testable (`deep-modules`).
- Stay language-free. Idiomatic realizations belong in `{lang}-dev` / overlays / project `AGENTS.md`.

## Done when

Pattern choice justified by named forces, or rejected; deletion test upheld on any new layer; co-load branch named when structure / type / boundary / perf work follows.
