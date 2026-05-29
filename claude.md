# CLAUDE.md

## Project Mission

This is a production Flutter application.

The primary goals are:

1. Maintainable architecture
2. Predictable state management
3. High test coverage
4. Performance optimization
5. Platform consistency
6. Minimal technical debt

Claude must prioritize consistency with the existing codebase over introducing new patterns.

---

# Architecture

## Required Architecture

Feature-first Clean Architecture.

```text
lib/
├── core/
│   ├── constants/
│   ├── extensions/
│   ├── services/
│   ├── network/
│   ├── storage/
│   ├── utils/
│   ├── widgets/
│   │   ├── custom_text.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_form_field.dart
│   │   └── custom_widgets.dart (barrel file)
│   ├── theme/
│   └── errors/
│
├── features/
│   ├── authentication/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   ├── views/
│   │   ├── widgets/
│   │   ├── repositories/
│   │   ├── models/
│   │   └── services/
│   │
│   └── ...
│
├── routes/
├── localization/
└── main.dart
```

Rules:

* UI never calls APIs directly.
* UI never accesses database directly.
* UI never contains business logic.
* Controllers coordinate actions.
* Repositories own data access.
* Services own external integrations.
* Models remain immutable whenever possible.

---

# State Management

## GetX Rules

Use:

* GetxController
* Bindings
* Rx variables

Avoid:

* Global mutable state
* Business logic in widgets
* API calls inside widgets

Bad:

```dart
onPressed: () async {
  final response = await dio.get(...);
}
```

Good:

```dart
onPressed: controller.loadProfile;
```

---

# Dependency Injection

All dependencies must be registered through Bindings.

Never instantiate services inside widgets.

Bad:

```dart
final api = ApiService();
```

Good:

```dart
Get.find<ApiService>();
```

---

# Widget Guidelines

## Reusable Common Widgets

All views and custom components must use the centralized, styled common widgets defined in [custom_widgets.dart](file:///Users/asset-611/Documents/Jay%20Gohil/Lyri/lyri_web/lib/core/widgets/custom_widgets.dart):
* **CustomText**: For text elements, supporting Inter/Outfit custom fonts, standard/secondary color systems, and localization helpers.
* **CustomButton**: For all action buttons, supporting standard solid states, modern gradient backings, outline styles, and built-in loader indicators.
* **CustomTextFormField**: For text inputs, incorporating premium glassmorphic border styles, validation states, and default input configurations.

Avoid using raw Flutter `Text`, `ElevatedButton`, `OutlinedButton`, or `TextFormField` directly unless custom behavior is required.

## Preferred Widget Order

1. Screen
2. Section Widget
3. Reusable Widget

Avoid:

* Widgets over 300 lines
* Deep nesting
* Massive build methods

When build() exceeds 100 lines:

Extract widgets.

---

# Performance Rules

Always:

* Use const constructors.
* Use ListView.builder.
* Use RepaintBoundary for expensive widgets.
* Cache network images.
* Dispose controllers and streams.

Avoid:

* Obx wrapping entire screens.
* Multiple nested FutureBuilders.
* Rebuilding large trees.

Bad:

```dart
Obx(() {
 return Scaffold(...);
});
```

Good:

```dart
Scaffold(
  body: Obx(() => Text(controller.name.value)),
);
```

---

# API Layer

## Networking

Use Dio.

Every API request must:

* Handle timeout
* Handle cancellation
* Handle unauthorized state
* Log failures

Required flow:

```text
Controller
  ↓
Repository
  ↓
ApiService
  ↓
Dio
```

---

# Error Handling

Never swallow exceptions.

Bad:

```dart
catch (_) {}
```

Good:

```dart
catch (e, stackTrace) {
  logger.e(
    e,
    stackTrace: stackTrace,
  );
}
```

All API failures should map to:

```dart
ApiException
NetworkException
ValidationException
UnauthorizedException
```

---

# Localization

All strings must be localized.

Forbidden:

```dart
Text("Login")
```

Required:

```dart
Text(LocaleKeys.login.tr)
```

---

# Models

Prefer:

```dart
const User({
 required this.id,
 required this.name,
});
```

Rules:

* Immutable
* Equatable or Freezed
* fromJson()
* toJson()

Never store business logic in models.

---

# Database

Preferred:

* Isar
* Floor

Rules:

* Repository layer owns queries.
* No direct database access from UI.
* Transactions for batch updates.

---

# Firebase

Firebase code belongs only in:

```text
services/firebase/
```

Includes:

* FCM
* Analytics
* Crashlytics
* Remote Config

Never call Firebase directly from UI.

---

# Logging

Use centralized logger.

Required logs:

* API requests
* API responses
* Errors
* Navigation events

Never log:

* Tokens
* Passwords
* Sensitive user data

---

# Security

Never:

* Hardcode API keys
* Hardcode secrets
* Commit certificates
* Store JWT in plain text

Use:

* flutter_secure_storage
* Environment variables
* Certificate pinning when available

---

# Testing Requirements

Minimum coverage target:

```text
Controllers: 80%
Repositories: 80%
Services: 80%
```

Required tests:

### Unit Tests

* Controller logic
* Repository logic
* Service logic

### Widget Tests

* Screen rendering
* User interaction
* Navigation

### Integration Tests

* Login
* Payment
* Critical user flows

Use:

```yaml
flutter_test
mocktail
integration_test
```

---

# Pull Request Rules

Before creating code:

Claude must check:

1. Existing architecture
2. Existing naming conventions
3. Existing dependency injection pattern
4. Existing repository structure
5. Existing route management

Do not introduce:

* Riverpod
* Bloc
* Provider
* MobX

Unless explicitly requested.

---

# Code Generation Rules

When generating code:

Always provide:

* Complete implementation
* Null-safe code
* Error handling
* Documentation comments
* Type-safe methods

Never provide:

* Pseudo code
* Placeholder implementations
* TODO comments unless requested

---

# Flutter Specific Rules

Prefer:

```dart
const
final
late final
```

in that order.

Avoid:

```dart
var
dynamic
```

unless necessary.

Always:

* Use mounted checks
* Cancel stream subscriptions
* Dispose controllers
* Handle lifecycle events

---

# Review Checklist

Before finishing a task, verify:

* Compiles successfully
* Analyzer clean
* No unused imports
* No duplicate logic
* Responsive UI
* Localization included
* Error handling present
* Tests added
* Documentation added

---

# Claude Code Operating Rules

Before modifying any file:

1. Read related files.
2. Understand dependencies.
3. Search for existing implementation.
4. Reuse existing patterns.

When uncertain:

* Ask questions.
* Do not invent architecture.

Priority Order:

1. Existing project conventions
2. Stability
3. Readability
4. Performance
5. New features

Generate code as if it will be deployed to production immediately.
