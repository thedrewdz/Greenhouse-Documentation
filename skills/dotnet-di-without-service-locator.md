# Skill: .NET Dependency Injection without Service Locator

## Purpose

Ensure Main Unit code uses explicit dependency injection and avoids service locator patterns.

## Use This Skill When

- Adding or refactoring services in C#.
- Wiring Program startup registrations.
- Reviewing code for hidden dependencies.

## Hard Rules

- Constructor injection is the default for required dependencies.
- Do not resolve services ad hoc from generic providers inside domain or application logic.
- Do not hide dependencies behind static accessors or global containers.
- Keep service lifetimes explicit and appropriate for usage.

## Design Rules

- Depend on minimal interfaces at call sites.
- Pass required collaborators explicitly.
- Keep composition root responsibilities in Program startup code.
- Use factories only when lifecycle or runtime selection requires it.

## Anti-Patterns to Reject

- Calling service-provider APIs from feature logic to fetch dependencies.
- Pulling optional dependencies at runtime to avoid constructor changes.
- Using locator helpers that wrap service-provider calls.

## Quality Gate

- All required dependencies are visible in constructors.
- No service locator usage appears in application or domain code.
- Registration graph is testable and understandable from startup configuration.

