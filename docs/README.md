# Riverpod Demo App

A comprehensive Flutter application demonstrating **Riverpod state management** from scratch, featuring authentication flow and CRUD operations.

## 📚 Table of Contents

- [What is Riverpod?](#what-is-riverpod)
- [Why Riverpod?](#why-riverpod)
- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Architecture](#project-architecture)
- [How Riverpod Works in This Project](#how-riverpod-works-in-this-project)
- [Implementation Guide](#implementation-guide)
- [Documentation](#documentation)

---

## What is Riverpod?

**Riverpod** is a reactive caching and data-binding framework for Flutter. It's a complete rewrite of the Provider package with several improvements:

- ✅ **Compile-safe** - Errors caught at compile time, not runtime
- ✅ **No BuildContext needed** - Access providers anywhere
- ✅ **Testable** - Easy to mock and test
- ✅ **No ProviderNotFoundException** - Type-safe provider access
- ✅ **Supports multiple instances** - Can have multiple providers of the same type

### Core Concept

Riverpod allows you to:

1. **Declare** providers that hold your state/logic
2. **Read** those providers from anywhere in your app
3. **Automatically rebuild** widgets when state changes

```dart
// 1. Declare a provider
final counterProvider = StateProvider<int>((ref) => 0);

// 2. Read in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider); // Auto-rebuild on change
    return Text('$count');
  }
}

// 3. Update from anywhere
ref.read(counterProvider.notifier).state++;
```

---

## Why Riverpod?

This project uses Riverpod because:

1. **Clean Architecture** - Clear separation between UI, state, and business logic
2. **Predictable State Flow** - Unidirectional data flow makes debugging easier
3. **Scalability** - Easy to add new features without breaking existing code
4. **Testability** - Each layer can be tested independently
5. **Type Safety** - Compile-time checks prevent common runtime errors

### Comparison with Other Solutions

| Feature            | setState | Provider | Riverpod |
| ------------------ | -------- | -------- | -------- |
| Compile-safe       | ❌       | ❌       | ✅       |
| No context needed  | ❌       | ❌       | ✅       |
| Easy testing       | ❌       | ⚠️       | ✅       |
| Multiple instances | ❌       | ❌       | ✅       |
| Auto-dispose       | ❌       | ⚠️       | ✅       |

---

## Project Overview

This demo app consists of two main modules:

### 1. Authentication Module

- **Splash Screen** - Checks authentication status
- **Login** - Username/password authentication
- **Home** - Dashboard with user greeting

### 2. Leave Request Module (Pengajuan Cuti)

- **List Page** - View all leave requests with status
- **Form Page** - Create/edit leave requests
- **Date Formatting** - Indonesian date display

### Tech Stack

- **Flutter SDK**: ^3.8.1
- **State Management**: Riverpod ^2.6.1
- **Local Storage**: SharedPreferences ^2.3.3
- **Language**: Dart

---

## Prerequisites

Before implementing or running this project, ensure you have:

### Required

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (^3.8.1 or higher)
- Dart SDK (comes with Flutter)
- An IDE (VS Code, Android Studio, or IntelliJ)
- Git

### Recommended

- Flutter & Dart extensions for your IDE
- Basic understanding of Flutter widgets
- Familiarity with async/await in Dart

### Verify Installation

```bash
# Check Flutter installation
flutter doctor

# Expected output:
# ✓ Flutter (Channel stable, 3.x.x)
# ✓ Android toolchain
# ✓ Xcode (for macOS)
# ✓ VS Code / Android Studio
```

---

## Getting Started

### 1. Clone & Setup

```bash
# Clone the repository
git clone <repository-url>
cd riverpod_demo_app

# Install dependencies
flutter pub get
```

### 2. Run the App

```bash
# Run on connected device/simulator
flutter run

# Or run on specific device
flutter devices          # List available devices
flutter run -d <device-id>
```

### 3. Test the Features

**Authentication Flow**:

1. App opens → Splash screen (2 seconds)
2. Not logged in → Login page appears
3. Enter any username/password (e.g., "admin" / "password")
4. Redirected to Home page

**Leave Request Module**:

1. From Home page, tap "Pengajuan Cuti" card
2. See list of demo leave requests
3. Tap "+" button to create new request
4. Fill form (dates, substitute, reason)
5. Submit and see it in the list
6. Edit or delete existing requests

---

## Project Architecture

### Folder Structure

```
lib/
├── main.dart                      # Entry point with ProviderScope
└── app/
    ├── models/                    # Data models
    │   └── leave_request.dart
    │
    ├── services/                  # Business logic
    │   ├── auth_service.dart
    │   └── leave_service.dart
    │
    ├── states/                    # State models
    │   ├── auth_state.dart
    │   └── leave_state.dart
    │
    ├── riverpod/
    │   └── providers/             # Riverpod providers
    │       ├── auth_provider.dart
    │       └── leave_provider.dart
    │
    ├── pages/                     # UI screens
    │   ├── splash_screen.dart
    │   ├── login_page.dart
    │   ├── home_page.dart
    │   ├── leave_list_page.dart
    │   └── leave_form_page.dart
    │
    └── utils/                     # Utilities
        └── date_formatter.dart
```

### Architecture Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Pages - ConsumerWidget/State)     │
│  • splash_screen.dart               │
│  • login_page.dart                  │
│  • home_page.dart                   │
│  • leave_list_page.dart             │
│  • leave_form_page.dart             │
├─────────────────────────────────────┤
│      State Management Layer         │
│  (Providers & StateNotifiers)       │
│  • auth_provider.dart               │
│  • leave_provider.dart              │
├─────────────────────────────────────┤
│          Business Logic             │
│  (Services)                         │
│  • auth_service.dart                │
│  • leave_service.dart               │
├─────────────────────────────────────┤
│           Data Layer                │
│  (Models & States)                  │
│  • leave_request.dart               │
│  • auth_state.dart                  │
│  • leave_state.dart                 │
└─────────────────────────────────────┘
```

---

## How Riverpod Works in This Project

### 1. Setup ProviderScope

**File**: [`lib/main.dart`](../lib/main.dart)

```dart
void main() {
  runApp(
    const ProviderScope(  // ← Root container for all providers
      child: MyApp(),
    ),
  );
}
```

**Purpose**: `ProviderScope` creates a container that holds all provider instances. Required at the app root.

---

### 2. Create Service Layer

**File**: [`lib/app/services/auth_service.dart`](../lib/app/services/auth_service.dart)

```dart
class AuthService {
  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('username', username);
    return true;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // ... more methods
}
```

**Purpose**: Contains business logic, separated from UI and state management.

---

### 3. Define State Models

**File**: [`lib/app/states/auth_state.dart`](../lib/app/states/auth_state.dart)

```dart
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? username;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.username,
    this.errorMessage,
  });

  // Immutable state updates
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? username,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

**Key Concept**: States are **immutable**. Use `copyWith()` to create new state instances.

---

### 4. Create StateNotifier

**File**: [`lib/app/riverpod/providers/auth_provider.dart`](../lib/app/riverpod/providers/auth_provider.dart)

```dart
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;

  AuthNotifier(this.authService) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    // 1. Update state to loading
    state = state.copyWith(isLoading: true);

    // 2. Call service
    final isLoggedIn = await authService.isLoggedIn();
    final username = await authService.getUsername();

    // 3. Update state with result
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: isLoggedIn,
      username: username,
    );
  }

  // ... more methods
}
```

**Purpose**: Manages state mutations and calls service methods.

---

### 5. Define Providers

**File**: [`lib/app/riverpod/providers/auth_provider.dart`](../lib/app/riverpod/providers/auth_provider.dart)

```dart
// Service provider (immutable)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// State provider (mutable)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
```

**Provider Types**:

- `Provider` - For immutable values (services, repositories)
- `StateNotifierProvider` - For mutable state with StateNotifier
- `StateProvider` - For simple mutable state (e.g., counters)

---

### 6. Use in Widgets

**File**: [`lib/app/pages/login_page.dart`](../lib/app/pages/login_page.dart)

```dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state - rebuilds when state changes
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          // Show loading indicator
          if (authState.isLoading)
            CircularProgressIndicator(),

          ElevatedButton(
            onPressed: () async {
              // Read notifier to call method
              final success = await ref
                  .read(authNotifierProvider.notifier)
                  .login(username, password);

              if (success) {
                Navigator.push(context, HomePage());
              }
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

**Key Methods**:

- `ref.watch()` - Subscribe to changes, widget rebuilds automatically
- `ref.read()` - Read once, no subscription (for callbacks)
- `ref.listen()` - Perform side effects (navigation, snackbars)

---

### Complete Data Flow

```
User Action (Button Tap)
    ↓
Widget: ref.read(provider.notifier).someMethod()
    ↓
StateNotifier: Updates state with state = state.copyWith(...)
    ↓
Widget: ref.watch(provider) detects change
    ↓
Widget: build() method re-runs
    ↓
UI Updates
```

---

## Implementation Guide

### When to Use Riverpod?

Use Riverpod when you need:

- ✅ State shared across multiple widgets
- ✅ Complex state logic (API calls, validation)
- ✅ Testable architecture
- ✅ Predictable state management

Use `setState()` when:

- ✅ Simple local widget state (text input, toggle)
- ✅ State not shared with other widgets
- ✅ No complex logic

### Step-by-Step Implementation

#### 1. Add Dependencies

**File**: `pubspec.yaml`

```yaml
dependencies:
  flutter_riverpod: ^2.6.1

dev_dependencies:
  riverpod_annotation: ^2.6.1
  riverpod_generator: ^2.6.2
  build_runner: ^2.4.13
```

Run: `flutter pub get`

---

#### 2. Wrap App with ProviderScope

**File**: `lib/main.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

#### 3. Create Your Service

**Example**: `lib/app/services/counter_service.dart`

```dart
class CounterService {
  int _counter = 0;

  int getCount() => _counter;

  void increment() => _counter++;

  void decrement() => _counter--;
}
```

---

#### 4. Create State Model

**Example**: `lib/app/states/counter_state.dart`

```dart
class CounterState {
  final int count;
  final bool isLoading;

  const CounterState({
    this.count = 0,
    this.isLoading = false,
  });

  CounterState copyWith({int? count, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
```

---

#### 5. Create StateNotifier

**Example**: `lib/app/riverpod/providers/counter_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterNotifier extends StateNotifier<CounterState> {
  final CounterService service;

  CounterNotifier(this.service) : super(const CounterState());

  void increment() {
    service.increment();
    state = state.copyWith(count: service.getCount());
  }

  void decrement() {
    service.decrement();
    state = state.copyWith(count: service.getCount());
  }
}
```

---

#### 6. Define Providers

**Example**: `lib/app/riverpod/providers/counter_provider.dart`

```dart
final counterServiceProvider = Provider<CounterService>((ref) {
  return CounterService();
});

final counterProvider = StateNotifierProvider<CounterNotifier, CounterState>((ref) {
  final service = ref.watch(counterServiceProvider);
  return CounterNotifier(service);
});
```

---

#### 7. Use in Widget

**Example**: `lib/app/pages/counter_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: ${counterState.count}',
                style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(counterProvider.notifier).decrement();
                  },
                  child: Text('-'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    ref.read(counterProvider.notifier).increment();
                  },
                  child: Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Common Patterns

#### Pattern 1: Loading States

```dart
Future<void> loadData() async {
  // 1. Set loading
  state = state.copyWith(isLoading: true);

  try {
    // 2. Fetch data
    final data = await service.fetchData();

    // 3. Update with data
    state = state.copyWith(isLoading: false, data: data);
  } catch (e) {
    // 4. Handle error
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}
```

#### Pattern 2: Side Effects with ref.listen

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Listen for state changes to show snackbar
  ref.listen(myProvider, (previous, next) {
    if (next.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.errorMessage!)),
      );
    }
  });

  final state = ref.watch(myProvider);
  return Scaffold(/*...*/);
}
```

#### Pattern 3: Cross-Provider Communication

```dart
class FormNotifier extends StateNotifier<FormState> {
  final Ref ref;

  FormNotifier(this.service, this.ref) : super(FormState());

  Future<void> submitForm() async {
    // ... submit logic

    // Refresh list provider after submission
    ref.read(listProvider.notifier).loadList();
  }
}
```

---

## Documentation

### Detailed Documentation

For in-depth explanations with code examples and flow diagrams:

📖 **[Phase 1 Documentation](RIVERPOD_PHASE_1.md)**

This includes:

- Complete authentication flow breakdown
- Leave request CRUD operations
- Data flow examples
- Best practices with file references
- Troubleshooting guide

### Quick Reference

| Need                | Use                  | Example                                        |
|---------------------|----------------------|------------------------------------------------|
| Watch state changes | `ref.watch()`        | `final state = ref.watch(myProvider);`         |
| Call method once    | `ref.read()`         | `ref.read(myProvider.notifier).doSomething();` |
| Side effects        | `ref.listen()`       | `ref.listen(myProvider, (prev, next) {...});`  |
| Immutable update    | `copyWith()`         | `state = state.copyWith(value: newValue);`     |
| Avoid build errors  | `Future.microtask()` | `Future.microtask(() => loadData());`          |

---

## Common Issues & Solutions

### Issue 1: "Tried to modify a provider while the widget tree was building"

**Solution**: Use `Future.microtask()` in `initState()`

```dart
@override
void initState() {
  super.initState();
  // ✅ Correct
  Future.microtask(() => ref.read(provider.notifier).loadData());

  // ❌ Wrong
  // ref.read(provider.notifier).loadData();
}
```

### Issue 2: Widget not rebuilding

**Check**: Are you using `ref.watch()`?

```dart
// ✅ Correct - rebuilds on change
final state = ref.watch(myProvider);

// ❌ Wrong - reads once, doesn't rebuild
final state = ref.read(myProvider);
```

### Issue 3: State not updating

**Check**: Are you using `copyWith()`?

```dart
// ✅ Correct - creates new state
state = state.copyWith(value: newValue);

// ❌ Wrong - mutating state directly
state.value = newValue;
```

---

## Next Steps

After understanding this README:

1. ✅ Run the app and explore features
2. ✅ Read [Phase 1 Documentation](RIVERPOD_PHASE_1.md) for detailed flows
3. ✅ Study file structure and code organization
4. ✅ Try adding your own feature using the same pattern
5. ✅ Experiment with different provider types

### Learning Path

```
1. README.md (You are here)
   ↓
2. Run the app and test features
   ↓
3. RIVERPOD_PHASE_1.md (Detailed flows)
   ↓
4. Read actual code files
   ↓
5. Implement your own feature
```

---

## Resources

### Official Documentation

- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Documentation](https://flutter.dev/docs)

### Community

- [Riverpod GitHub](https://github.com/rrousselGit/riverpod)
- [Flutter Community](https://flutter.dev/community)

---

## License

This is a demo project for learning purposes.

---

**Happy Coding! 🚀**
