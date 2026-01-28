# ADR-0001: Clean Architecture with Domain-Driven Design

## Status

Accepted

## Context

I needed to establish a foundational architecture for an enterprise Flutter application that:

1. **Scales** with team size and codebase complexity
2. **Testable** with high coverage and isolated unit tests
3. **Maintainable** with clear separation of concerns
4. **Flexible** to swap implementations (databases, APIs, services)
5. **Domain-focused** to model complex business rules accurately

Traditional Flutter architectures (like simple MVC or Provider-only) often lead to:
- Business logic scattered across widgets
- Tight coupling between UI and data sources
- Difficulty testing without the Flutter framework
- Hard-to-maintain codebases as features grow

## Decision

I adopt **Clean Architecture** combined with **Domain-Driven Design (DDD) tactical patterns** and **Hexagonal Architecture** (Ports & Adapters).

### Layer Structure

```
┌─────────────────────────────────────────┐
│           PRESENTATION                   │
│   BLoC, Pages, Widgets, UI Mappers      │
├─────────────────────────────────────────┤
│           APPLICATION                    │
│   Commands, Queries, Use Cases          │
├─────────────────────────────────────────┤
│              DOMAIN                      │
│   Entities, Value Objects, Ports        │
├─────────────────────────────────────────┤
│          INFRASTRUCTURE                  │
│   Repositories, Data Sources, APIs      │
└─────────────────────────────────────────┘
```

### Key Principles

1. **Dependency Rule**: Dependencies only point inward. Domain knows nothing about Infrastructure.
2. **Ports & Adapters**: Define interfaces (ports) in Domain, implement in Infrastructure.
3. **Rich Domain Model**: Entities contain behavior, not just data.
4. **CQRS**: Separate Commands (writes) from Queries (reads).

## Consequences

### Positive

- **Testability**: Domain and Application layers are pure Dart—testable without Flutter
- **Maintainability**: Each layer has a single responsibility
- **Flexibility**: Swap data sources without touching business logic
- **Team Scalability**: Clear boundaries enable parallel development
- **Onboarding**: New developers understand where code belongs

### Negative

- **Initial Complexity**: More boilerplate than simple architectures
- **Learning Curve**: Team must understand DDD concepts
- **Over-engineering Risk**: Simple features may feel heavy

### Neutral

- Requires code generation (freezed, injectable) for practical use
- Each feature follows the same folder structure

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design by Eric Evans](https://www.domainlanguage.com/ddd/)
- [Hexagonal Architecture by Alistair Cockburn](https://alistair.cockburn.us/hexagonal-architecture/)
