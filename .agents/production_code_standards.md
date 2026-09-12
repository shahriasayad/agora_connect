# PRODUCTION CODE STANDARDS

## 1. ENGINEERING STANDARD

All code must be written as if it will be maintained by a professional engineering team for many years.

Code must prioritize:

- Correctness
- Clarity
- Maintainability
- Reliability
- Security
- Testability
- Performance
- Scalability

"Works on my machine" is not an acceptable quality standard.


# 2. SIMPLICITY

Prefer the simplest solution that fully satisfies the requirement.

Avoid:

- Overengineering
- Premature abstraction
- Unnecessary patterns
- Excessive indirection
- Duplicate implementations
- Frameworks/packages without clear value

Simple does not mean careless.

Simple means the smallest design that correctly solves the problem.


# 3. RESPONSIBILITY

Every class, file, method, and component should have a clear responsibility.

Avoid:

- God classes
- God controllers
- Giant widgets
- Giant services
- Methods that perform unrelated operations
- Business logic mixed with presentation
- Data access mixed with UI


# 4. NAMING

Names must describe intent.

Use meaningful names for:

- Classes
- Methods
- Variables
- Constants
- Files
- Routes
- Models
- Services
- Controllers

Avoid vague names such as:

- data
- item
- temp
- helper
- manager
- stuff
- test
- new
- old

unless the context genuinely makes the name precise.


# 5. METHODS

Methods should:

- Do one meaningful thing.
- Be easy to understand.
- Have predictable inputs/outputs.
- Avoid unnecessary side effects.
- Avoid deep nesting.

If a method becomes difficult to understand, split it by responsibility.


# 6. STATE

State must have one clear owner.

Avoid:

- Duplicate state
- State copied between layers unnecessarily
- UI pretending to own business state
- Stale cached state
- Conflicting sources of truth

Every state transition should have a clear cause.


# 7. DATA FLOW

Data should flow predictably:

Input
→ Validation
→ Business logic
→ Data/service layer
→ Result
→ State update
→ UI

Do not bypass established layers without a strong reason.


# 8. ERROR QUALITY

Errors must be:

- Detected
- Handled
- Logged appropriately
- Communicated appropriately
- Recoverable when possible

Never hide errors.

Never use exception suppression as a solution.

Never convert failure into fake success.


# 9. ASYNC CODE

Async operations must correctly handle:

- Loading
- Success
- Failure
- Cancellation where applicable
- Timeout where applicable
- Lifecycle/disposal
- Duplicate requests

Avoid race conditions and stale responses.

Do not assume asynchronous operations complete in the order they started.


# 10. RESOURCE MANAGEMENT

Anything created must have a defined lifecycle.

Verify cleanup for:

- Controllers
- Streams
- Listeners
- Timers
- Subscriptions
- SDK instances
- Files
- Database resources
- Network resources
- Platform resources

No memory leaks.

No duplicate listeners.

No stale callbacks.


# 11. UI QUALITY

UI code must be:

- Responsive
- Consistent
- Accessible where applicable
- Maintainable
- State-aware

Every user-facing screen should consider:

- Loading
- Empty
- Success
- Error
- Disabled
- Offline
- Long content
- Small screens
- Large screens
- Keyboard/safe-area behavior

Do not expose raw technical state to users.


# 12. DESIGN SYSTEM

When a project has a design system:

Always reuse:

- Colors
- Typography
- Spacing
- Components
- Icons
- Themes
- Constants
- Animations

Do not create local versions of existing design-system components.

If no design system exists, establish one only when the project is large enough to benefit from it.


# 13. API QUALITY

API integrations must:

- Use centralized networking where available.
- Use typed models where appropriate.
- Validate responses.
- Handle failures.
- Handle authentication correctly.
- Avoid duplicate requests.
- Avoid hardcoded environment-specific values.

Never assume an API contract.

Verify it.


# 14. SECURITY

Never expose:

- Passwords
- Tokens
- API secrets
- Private keys
- Certificates
- Sensitive user data

in:

- Source control
- Logs
- UI
- Error messages
- Analytics
- Debug output

Use secure storage/configuration where required.


# 15. DEPENDENCY QUALITY

Every dependency creates:

- Maintenance cost
- Security surface
- Build complexity
- Compatibility risk

Therefore:

Use a dependency only when it provides meaningful value.

Before adding one:

1. Search existing code.
2. Search existing dependencies.
3. Determine whether the feature can be implemented cleanly without it.
4. Check compatibility.
5. Confirm platform impact.


# 16. PERFORMANCE

Performance work must be evidence-driven.

Prioritize:

- Correct lifecycle
- Efficient state updates
- Avoiding unnecessary rebuilds
- Avoiding duplicate requests
- Efficient collections
- Proper resource cleanup
- Appropriate caching

Do not sacrifice readability for theoretical performance.


# 17. BACKWARD COMPATIBILITY

When modifying existing functionality:

- Preserve existing behavior unless the requirement explicitly changes it.
- Consider existing users/data.
- Consider existing API contracts.
- Consider navigation.
- Consider persisted state.
- Consider platform differences.

Breaking changes must be intentional.


# 18. TESTABILITY

Code should be structured so important behavior can be tested.

Prefer:

- Deterministic logic
- Clear dependencies
- Small responsibilities
- Predictable state transitions
- Testable services/controllers

Avoid tightly coupled implementations that are difficult to verify.


# 19. EDGE CASES

Before completion consider:

- Empty input
- Invalid input
- Null/missing data
- Network failure
- Timeout
- Permission denial
- Duplicate actions
- Rapid repeated actions
- App restart
- Background/foreground
- Account switching
- Logout
- Partial failure
- Unexpected API response
- Resource disposal


# 20. CODE CLEANLINESS

Before completing work:

Remove:

- Dead code
- Unused imports
- Unused variables
- Temporary debugging
- Commented-out obsolete code
- Duplicate implementations
- Temporary workarounds

Do not leave the repository in a worse state than you found it.


# 21. CHANGE DISCIPLINE

Every change should have a reason.

Prefer:

Small
→ focused
→ complete
→ verifiable

over:

Large
→ broad
→ speculative
→ difficult to test


# 22. ARCHITECTURAL CHANGES

Do not introduce architectural changes casually.

An architectural change requires a clear reason such as:

- Existing architecture cannot support the requirement.
- Existing design causes repeated defects.
- A scalability limitation is proven.
- Security requires a different boundary.
- Maintainability requires separation.

When making architectural changes:

1. Explain the problem.
2. Identify the current limitation.
3. Define the proposed boundary.
4. Migrate safely.
5. Verify affected flows.


# 23. PRODUCTION READINESS

Before considering a feature complete, verify:

- Correct behavior
- Error handling
- Loading states
- Empty states
- Lifecycle
- Security
- Performance
- Accessibility where relevant
- Platform behavior
- Regression safety
- Tests
- Build

A feature is not complete merely because the happy path works.


# 24. VERIFICATION STANDARD

The level of verification must match the risk.

Low-risk UI change:
- Analyze/lint
- Build
- Manual verification

Business-critical logic:
- Unit tests
- Integration tests where appropriate
- Edge-case verification

Platform/infrastructure change:
- Build verification
- Runtime verification
- Platform-specific testing

Never report verification that was not actually performed.


# 25. LEGACY CODE

Do not automatically rewrite legacy code.

First determine:

- What works
- What is broken
- Why it is structured that way
- What depends on it
- What risk a rewrite creates

Improve incrementally unless a rewrite is technically justified.


# 26. FRESH PROJECTS

For new projects:

- Establish only the architecture actually required.
- Establish conventions early.
- Avoid premature complexity.
- Create reusable foundations only where repetition is expected.
- Define testing and error-handling strategy early.
- Keep future scalability in mind without implementing unused infrastructure.


# 27. EXISTING PROJECTS

For existing projects:

- Preserve working behavior.
- Follow established conventions.
- Reuse existing infrastructure.
- Minimize file changes.
- Avoid unrelated refactoring.
- Identify technical debt only when relevant to the task.
- Improve weak areas incrementally.


# 28. FINAL QUALITY CHECK

Before delivery, confirm:

[ ] Requirement completely implemented
[ ] Existing behavior preserved
[ ] Architecture respected
[ ] Root cause addressed
[ ] No duplicate logic
[ ] No unnecessary dependencies
[ ] No unnecessary files
[ ] No debug code
[ ] Errors handled
[ ] Loading handled
[ ] Empty states handled
[ ] Edge cases considered
[ ] Resources disposed
[ ] Security considered
[ ] Performance considered
[ ] Tests/verification completed
[ ] Build succeeds
[ ] No known issue intentionally hidden


# FINAL STANDARD

The code must be something a senior engineer would be comfortable owning.

Do not optimize for:

"Can this run?"

Optimize for:

"Is this correct?"

"Is this understandable?"

"Will this remain correct?"

"Can another engineer safely modify it?"

"Can we test it?"

"Does it fit the existing system?"

"Did we introduce unnecessary complexity?"

If the answer to any important question is no, the work is not finished.