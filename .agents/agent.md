# AI Development Rules (Mandatory)
These rules apply to **every** task, including new features, bug fixes, refactoring, API integration, UI implementation, optimization, and code generation. Follow them strictly without exception.
—

# Core Mindset
Do not behave like a code generator.
Behave like a senior software engineer working inside an existing production codebase.
Before making any change:
* Understand the existing architecture.
* Understand the data flow.
* Understand the business logic.
* Understand dependencies and side effects.
* Understand the root cause of the issue.
* Never guess.
* Never assume.
* Always inspect the existing implementation before making changes.
Accuracy is more important than speed.
Understanding is more important than coding.
—

# Flutter Architecture
* Use **Flutter + GetX** only.
* Use **StatelessWidget** only. use **StatefulWidget** only when it really requred.
* Keep all business logic, state management, validation, filtering, pagination, calculations, API handling, and data flow inside **controllers** and **services**.
* Screens should contain only:
  * UI rendering
  * Widget composition
  * Navigation triggers
  * Small UI conditions
* Follow the existing feature-based architecture:
```text
feature/
  controller/
  service/
  screen/
  widgets/
```
Keep responsibilities separated and consistent.
—

# Reuse Before Creating
Before creating any new:
* Widget
* Helper
* Service
* Validator
* Extension
* Dialog
* Bottom Sheet
* AppBar
* Button
* Utility
* Constant
* Theme
* Model
* Controller
Search the existing project first.
If an implementation already exists:
* Reuse it.
* Extend it if necessary.
* Never duplicate widgets or logic.
—

# Respect the Existing Project
The existing project is the source of truth.
Always follow existing:
* Architecture
* Folder structure
* Naming conventions
* State management
* API patterns
* UI patterns
* Theme system
* Shared widgets
* Services
* Controllers
Do not replace established project patterns with personal preferences.
Consistency is mandatory.
—

# UI Rules
Match provided Figma or reference images as closely as possible.
Aim for pixel-perfect implementation by matching:
* Layout
* Spacing
* Padding
* Typography
* Border radius
* Icons
* Shadows
* Alignment
* Component sizing
Always use existing project:
* Colors
* Themes
* Constants
* Shared widgets
Never hardcode colors.
Use existing typography helpers (such as `getTextStyle`) instead of creating new `TextStyle` instances unless absolutely necessary.
—

# Root Cause First
Never fix symptoms.
Always find and fix the real root cause.
Before writing code:
* Trace the complete flow.
* Identify where the issue starts.
* Verify why it happens.
* Confirm the cause from the existing code.
A fix is incomplete if the root cause still exists.
—

# Fix Related Issues Together
When fixing a bug:
Do not only fix the exact failing line.
Review the complete related flow.
If the same issue can occur elsewhere:
* Fix those locations too.
* Prevent the issue from happening again.
One implementation should solve the complete problem whenever logically possible.
—

# Learn From Previous Mistakes
If a bug was caused by:
* Wrong API mapping
* Wrong endpoint
* Wrong field name
* Wrong state handling
* Missing validation
* Incorrect architecture usage
* Incorrect data flow
Check the rest of the project for the same mistake.
Do not repeat previously identified issues.
—

# No Assumptions
Never assume:
* APIs
* Endpoints
* Routes
* Widgets
* Models
* Services
* Helpers
* Colors
* Constants
* Field names
* Imports
* Methods
* Classes
Verify everything from the existing project before generating code.
—

# Code Quality
All code must be:
* Clean
* Readable
* Maintainable
* Production-ready
* Consistent
* Scalable
* Logical
Avoid:
* Quick hacks
* Temporary fixes
* Duplicate code
* Overengineering
* Unnecessary abstractions
* Complex solutions when simple ones work
Prefer the simplest solution that correctly solves the problem.
—

# File Organization
Keep files small, focused, and maintainable.
If a file becomes too large:
* Split responsibilities logically.
* Extract reusable widgets.
* Keep screens lightweight.
* Keep code easy to navigate.
Use meaningful names for:
* Files
* Widgets
* Controllers
* Variables
* Methods
Avoid generic names.
—

# Validation Before Code Generation
Before generating or modifying code, verify:
* Imports are correct.
* Classes exist.
* Widgets exist.
* Methods exist.
* Dependencies exist.
* Routes exist.
* API mappings are correct.
* Field names match the backend.
* Models match the API.
* Logic flow is correct.
Never generate code that references non-existent files, widgets, methods, or classes.
—

# Comments Policy
Do not add unnecessary comments.
Only comment:
* Complex business logic
* Important architectural decisions
* Non-obvious behavior
* Section headers in large controllers
Do not comment obvious code.
Clean code should explain itself.
—

# Error Handling
Use the project's existing error handling approach.
Use **EasyLoading** instead of **SnackBar** unless explicitly requested otherwise.
—

# Development Workflow
For every task:
1. Understand the requirement.
2. Understand the current implementation.
3. Trace the complete flow.
4. Find the root cause.
5. Identify related issues.
6. Reuse existing implementations whenever possible.
7. Implement the cleanest solution.
8. Verify no similar issue remains.
9. Ensure the implementation follows the existing project architecture.
10. Deliver a complete working solution.
Never skip these steps.
—

# Final Rule 
Think before changing code.
Understand before implementing.
Reuse before creating.
Fix the root cause instead of the symptom.
Maintain consistency with the existing codebase.
One change should solve the complete problem whenever logically possible.
Every generated solution must be clean, simple, production-ready, maintainable, and fully aligned with the existing project architecture.
Inspect lib/core
At minimum, review these files:
 (And if this all files and widgets are not been created then 1st create them)
app_colors.dart
icon_path.dart
image_path.dart
custom_appbar.dart
custom_button.dart
custom_text_field.dart
global_text_style.dart
api_logger.dart
api_client.dart
Shared_preference_helper.dart
