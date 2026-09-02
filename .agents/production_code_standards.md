# Production Code Standards
You are working on a production application. Every implementation must be written as if it will be maintained by a large engineering team for years. Prioritize correctness, simplicity, maintainability, and scalability over writing code that merely "works."

## Engineering Principles
- Write production-quality code only.
- Keep the implementation simple, clean, and easy to understand.
- Prefer clarity over clever or overly abstract solutions.
- Think like a Senior Software Engineer, not just a feature implementer.
- Fully understand the existing feature before making changes.
- Analyze the complete flow, dependencies, and side effects before modifying any code.

## Architecture
- Follow the existing project architecture consistently.
- Reuse the current controllers, services, repositories, models, widgets, utilities, helpers, and shared components.
- Extend existing implementations instead of introducing parallel solutions.
- Maintain a single source of truth for shared logic.
- Keep business logic inside controllers/services and UI logic inside widgets.
- Do not introduce new architectural patterns unless there is a clear technical need.

## Code Quality
- Follow Clean Code and SOLID principles where appropriate.
- Keep every class, file, and method focused on a single responsibility.
- Use meaningful names for files, classes, methods, variables, and constants.
- Keep methods short and cohesive.
- Eliminate duplicate logic by extracting reusable code.
- Remove dead code, unused variables, unused imports, and obsolete implementations.
- Avoid deep nesting and unnecessary complexity.

## Root Cause First
- Always identify and fix the root cause.
- Never apply temporary fixes, hacks, or workarounds.
- Do not suppress errors to hide issues.
- Verify the entire feature flow before deciding on a solution.

## Consistency
- Follow the project's existing coding style and naming conventions.
- Keep folder structure consistent.
- Keep similar features implemented in the same way.
- Do not create multiple approaches for solving the same problem.

## Performance
- Avoid unnecessary widget rebuilds.
- Avoid duplicate API calls.
- Avoid duplicate state.
- Dispose controllers, streams, listeners, and subscriptions correctly.
- Optimize only where it provides measurable value.
- Keep memory usage efficient.

## Error Handling
- Handle all success, loading, empty, and failure states.
- Handle exceptions gracefully.
- Never leave loading states active indefinitely.
- Use the project's shared logging and error handling.
- Do not swallow exceptions silently.

## State Management
- Keep state predictable and centralized.
- Prevent stale or duplicated state.
- Ensure state updates correctly after navigation, refresh, login/logout, and account switching.
- Dispose resources properly.

## API Integration
- Reuse the shared networking layer.
- Keep request and response handling centralized.
- Avoid hardcoded values.
- Respect existing models and response structures.
- Keep API handling consistent across the project.

## Verification
Before completing any task:
- Review the complete feature flow.
- Review all related controllers, services, models, widgets, routes, and APIs.
- Check for regressions.
- Verify edge cases.
- Verify account switching if applicable.
- Verify loading, error, and success states.
- Ensure existing functionality remains unchanged.

## Constraints
- Do not guess.
- Do not assume behavior without verifying the implementation.
- Do not hardcode values that should come from configuration or backend.
- Do not duplicate business logic.
- Do not introduce unnecessary dependencies.
- Do not create new patterns when an existing one already solves the problem.
- Keep the solution minimal while remaining scalable.

## Final Goal
Every change should improve the overall quality of the codebase. The final implementation should be clean, consistent, maintainable, scalable, and ready for long-term production use by a professional engineering team.