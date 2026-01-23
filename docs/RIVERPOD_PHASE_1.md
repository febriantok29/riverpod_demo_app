# Riverpod Demo App - Phase 1 Documentation

## Overview

This is a comprehensive Flutter application demonstrating **Riverpod state management** with a real-world authentication and leave request management system. The project follows clean architecture principles with clear separation of concerns.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Authentication Flow](#authentication-flow)
3. [Leave Request Module](#leave-request-module)
4. [Riverpod Concepts](#riverpod-concepts)
5. [File Structure](#file-structure)
6. [Data Flow Examples](#data-flow-examples)

---

## Architecture Overview

The app follows a layered architecture:

```
┌─────────────────────────────────────┐
│           UI Layer                  │
│  (Pages - ConsumerWidget)           │
├─────────────────────────────────────┤
│     State Management Layer          │
│  (Providers & StateNotifiers)       │
├─────────────────────────────────────┤
│        Service Layer                │
│  (Business Logic)                   │
├─────────────────────────────────────┤
│         Data Layer                  │
│  (Models & Local Storage)           │
└─────────────────────────────────────┘
```

### Key Principles

1. **Unidirectional Data Flow**: Data flows from services → notifiers → widgets
2. **Immutable State**: All states are immutable with `copyWith` pattern
3. **Separation of Concerns**: Each layer has a single responsibility
4. **Provider-based DI**: Dependencies injected through Riverpod providers

---

## Authentication Flow

### Files Involved

1. **Models**: [`lib/app/models/`](../lib/app/models/) - None (state only)
2. **Services**: [`lib/app/services/auth_service.dart`](../lib/app/services/auth_service.dart)
3. **States**: [`lib/app/states/auth_state.dart`](../lib/app/states/auth_state.dart)
4. **Providers**: [`lib/app/riverpod/providers/auth_provider.dart`](../lib/app/riverpod/providers/auth_provider.dart)
5. **Pages**:
   - [`lib/app/pages/splash_screen.dart`](../lib/app/pages/splash_screen.dart)
   - [`lib/app/pages/login_page.dart`](../lib/app/pages/login_page.dart)
   - [`lib/app/pages/home_page.dart`](../lib/app/pages/home_page.dart)

### Flow Diagram

```
App Start
    ↓
main.dart (ProviderScope wraps app)
    ↓
splash_screen.dart
    ├→ initState: Future.microtask(() => _checkAuthStatus())
    ├→ Read: authNotifierProvider.notifier
    ├→ Call: checkAuthStatus()
    │     ↓
    │   auth_provider.dart (AuthNotifier)
    │     ├→ Update state: isLoading = true
    │     ├→ Call: authService.isLoggedIn()
    │     ├→ Call: authService.getUsername()
    │     └→ Update state: isAuthenticated, username
    │
    └→ Navigate based on state:
        ├→ isAuthenticated = true  → home_page.dart
        └→ isAuthenticated = false → login_page.dart
```

### Step-by-Step Authentication Flow

#### 1. App Initialization ([`main.dart`](../lib/main.dart))

```dart
void main() {
  runApp(
    const ProviderScope(  // ← Riverpod container
      child: MyApp(),
    ),
  );
}
```

**Purpose**: `ProviderScope` creates the Riverpod container that holds all providers.

---

#### 2. Splash Screen ([`splash_screen.dart`](../lib/app/pages/splash_screen.dart))

**Entry Point**: Lines 15-20

```dart
@override
void initState() {
  super.initState();
  // Delay execution until widget tree is built
  Future.microtask(() => _checkAuthStatus());
}
```

**Key Concept**: `Future.microtask()` ensures provider updates happen after the widget tree is built, avoiding the "modifying provider during build" error.

**Authentication Check**: Lines 22-38

```dart
Future<void> _checkAuthStatus() async {
  // Read notifier to call method
  await ref.read(authNotifierProvider.notifier).checkAuthStatus();

  // Wait for splash effect
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  // Read state to check authentication
  final authState = ref.read(authNotifierProvider);

  // Navigate based on state
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => authState.isAuthenticated
          ? const HomePage()
          : const LoginPage(),
    ),
  );
}
```

**Flow**:

1. `ref.read(authNotifierProvider.notifier)` → Gets the `AuthNotifier` instance
2. `.checkAuthStatus()` → Calls method in [`auth_provider.dart`](../lib/app/riverpod/providers/auth_provider.dart#L17-L28)
3. `ref.read(authNotifierProvider)` → Gets the current `AuthState`
4. Navigate based on `isAuthenticated` flag

---

#### 3. Auth Provider ([`auth_provider.dart`](../lib/app/riverpod/providers/auth_provider.dart))

**Provider Definitions**: Lines 6-16

```dart
// Service Provider (singleton)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StateNotifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
```

**Check Auth Status Method**: Lines 17-28

```dart
Future<void> checkAuthStatus() async {
  // 1. Set loading state
  state = state.copyWith(isLoading: true);

  // 2. Call service layer
  final isLoggedIn = await authService.isLoggedIn();
  final username = await authService.getUsername();

  // 3. Update state with results
  state = state.copyWith(
    isLoading: false,
    isAuthenticated: isLoggedIn,
    username: username,
  );
}
```

**Flow Path**:

```
AuthNotifier.checkAuthStatus()
    ↓
AuthService.isLoggedIn()  [auth_service.dart:10-14]
    ↓
SharedPreferences.getBool('is_logged_in')
    ↓
Return to AuthNotifier
    ↓
Update AuthState
    ↓
Widget rebuilds (watching provider)
```

---

#### 4. Login Process ([`login_page.dart`](../lib/app/pages/login_page.dart))

**Form Submission**: Lines 28-49

```dart
Future<void> _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    // Call login method
    final success = await ref.read(authNotifierProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (mounted) {
      // Show error
      final errorMessage = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Login gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Login Method in Provider** ([`auth_provider.dart:30-50`](../lib/app/riverpod/providers/auth_provider.dart#L30-L50)):

```dart
Future<bool> login(String username, String password) async {
  // 1. Set loading state
  state = state.copyWith(isLoading: true, errorMessage: null);

  // 2. Call service
  final success = await authService.login(username, password);

  // 3. Update state based on result
  if (success) {
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      username: username,
    );
  } else {
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Username atau password tidak boleh kosong',
    );
  }

  return success;
}
```

**Complete Flow**:

```
login_page.dart: _handleLogin()
    ↓
auth_provider.dart: login(username, password)
    ↓
    state.isLoading = true
    ↓
auth_service.dart: login(username, password)
    ↓
    SharedPreferences.setBool('is_logged_in', true)
    SharedPreferences.setString('username', username)
    ↓
    return true
    ↓
auth_provider.dart: state.isAuthenticated = true
    ↓
login_page.dart: Navigate to HomePage
```

---

## Leave Request Module

### Files Involved

1. **Models**: [`lib/app/models/leave_request.dart`](../lib/app/models/leave_request.dart)
2. **Services**: [`lib/app/services/leave_service.dart`](../lib/app/services/leave_service.dart)
3. **States**: [`lib/app/states/leave_state.dart`](../lib/app/states/leave_state.dart)
4. **Providers**: [`lib/app/riverpod/providers/leave_provider.dart`](../lib/app/riverpod/providers/leave_provider.dart)
5. **Pages**:
   - [`lib/app/pages/leave_list_page.dart`](../lib/app/pages/leave_list_page.dart)
   - [`lib/app/pages/leave_form_page.dart`](../lib/app/pages/leave_form_page.dart)
6. **Utils**: [`lib/app/utils/date_formatter.dart`](../lib/app/utils/date_formatter.dart)

### Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│  UI Layer                                           │
│  - leave_list_page.dart (displays list)            │
│  - leave_form_page.dart (create/edit form)         │
└─────────────────┬───────────────────────────────────┘
                  │ ref.watch() / ref.read()
┌─────────────────▼───────────────────────────────────┐
│  State Management Layer                             │
│  - leave_provider.dart                              │
│    ├─ LeaveListNotifier (manages list state)       │
│    └─ LeaveFormNotifier (manages form state)       │
└─────────────────┬───────────────────────────────────┘
                  │ calls methods
┌─────────────────▼───────────────────────────────────┐
│  Service Layer                                      │
│  - leave_service.dart                               │
│    ├─ CRUD operations                               │
│    └─ In-memory storage                             │
└─────────────────┬───────────────────────────────────┘
                  │ uses
┌─────────────────▼───────────────────────────────────┐
│  Data Layer                                         │
│  - leave_request.dart (Model)                       │
│  - leave_state.dart (State models)                  │
└─────────────────────────────────────────────────────┘
```

### Leave List Flow

#### 1. Page Initialization ([`leave_list_page.dart:18-25`](../lib/app/pages/leave_list_page.dart#L18-L25))

```dart
@override
void initState() {
  super.initState();
  // Load data when page opens
  Future.microtask(() {
    final username = ref.read(authNotifierProvider).username ?? 'User';
    // Seed demo data for first time
    ref.read(leaveListProvider.notifier).seedDemoData(username);
  });
}
```

**What happens**:

1. Get current username from `authNotifierProvider`
2. Call `seedDemoData()` in [`leave_provider.dart:41-44`](../lib/app/riverpod/providers/leave_provider.dart#L41-L44)
3. Seeds demo data in [`leave_service.dart:104-141`](../lib/app/services/leave_service.dart#L104-L141)
4. Automatically calls `loadLeaveRequests()` which updates state

#### 2. Watching State Changes ([`leave_list_page.dart:29-30`](../lib/app/pages/leave_list_page.dart#L29-L30))

```dart
@override
Widget build(BuildContext context) {
  final leaveState = ref.watch(leaveListProvider);  // ← Reactive rebuild
  final username = ref.watch(authNotifierProvider).username ?? 'User';
  // ...
}
```

**Key Concept**:

- `ref.watch()` subscribes to state changes
- Widget automatically rebuilds when `LeaveListState` changes
- This happens in [`leave_provider.dart`](../lib/app/riverpod/providers/leave_provider.dart) when `state = ...` is called

#### 3. Loading Data ([`leave_provider.dart:19-31`](../lib/app/riverpod/providers/leave_provider.dart#L19-L31))

```dart
Future<void> loadLeaveRequests() async {
  // 1. Set loading state → triggers UI rebuild
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    // 2. Fetch from service
    final requests = await leaveService.getAllLeaveRequests();

    // 3. Update state with data → triggers UI rebuild
    state = state.copyWith(
      isLoading: false,
      leaveRequests: requests,
    );
  } catch (e) {
    // 4. Update state with error → triggers UI rebuild
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Gagal memuat data: ${e.toString()}',
    );
  }
}
```

**State Transitions**:

```
Initial State:
LeaveListState(isLoading: false, leaveRequests: [], errorMessage: null)
    ↓
loadLeaveRequests() called
    ↓
State 1: LeaveListState(isLoading: true, leaveRequests: [], errorMessage: null)
    ↓ UI shows loading indicator
Service call completes
    ↓
State 2: LeaveListState(isLoading: false, leaveRequests: [data...], errorMessage: null)
    ↓ UI shows list
```

### Leave Form Flow

#### 1. Form State Management ([`leave_form_page.dart:43-48`](../lib/app/pages/leave_form_page.dart#L43-L48))

```dart
@override
void initState() {
  super.initState();

  // If edit mode, populate existing data
  if (isEditMode) {
    _startDate = widget.existingLeave!.startDate;
    _endDate = widget.existingLeave!.endDate;
    _substituteController.text = widget.existingLeave!.substitute;
    _reasonController.text = widget.existingLeave!.reason;
  }

  // Reset form state
  Future.microtask(() {
    ref.read(leaveFormProvider.notifier).resetFormState();
  });
}
```

#### 2. Listening to State Changes ([`leave_form_page.dart:60-75`](../lib/app/pages/leave_form_page.dart#L60-L75))

```dart
// Listen for state changes to perform side effects
ref.listen(leaveFormProvider, (previous, next) {
  if (next.isSuccess) {
    // Success: pop back and show snackbar
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditMode
              ? 'Pengajuan berhasil diupdate'
              : 'Pengajuan cuti berhasil dibuat',
        ),
        backgroundColor: Colors.green,
      ),
    );
  } else if (next.errorMessage != null && !next.isLoading) {
    // Error: show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(next.errorMessage!),
        backgroundColor: Colors.red,
      ),
    );
  }
});
```

**Key Concept**: `ref.listen()` vs `ref.watch()`

- `ref.watch()` → Rebuilds widget when state changes
- `ref.listen()` → Performs side effects (navigation, snackbars) when state changes

#### 3. Form Submission ([`leave_form_page.dart:430-446`](../lib/app/pages/leave_form_page.dart#L430-L446))

```dart
Future<void> _handleSubmit() async {
  // Validation
  if (!_formKey.currentState!.validate()) return;
  if (_startDate == null || _endDate == null) {
    // Show error
    return;
  }

  final notifier = ref.read(leaveFormProvider.notifier);

  if (isEditMode) {
    // Update existing
    await notifier.updateLeaveRequest(
      id: widget.existingLeave!.id,
      startDate: _startDate!,
      endDate: _endDate!,
      substitute: _substituteController.text,
      reason: _reasonController.text,
    );
  } else {
    // Create new
    await notifier.createLeaveRequest(
      employeeName: widget.employeeName,
      startDate: _startDate!,
      endDate: _endDate!,
      substitute: _substituteController.text,
      reason: _reasonController.text,
    );
  }
}
```

**Complete Create Flow**:

```
leave_form_page.dart: _handleSubmit()
    ↓
leave_provider.dart: createLeaveRequest()
    ↓
    State 1: LeaveFormState(isLoading: true)
    ↓ UI shows loading button
leave_service.dart: createLeaveRequest()
    ↓
    Create new LeaveRequest object
    Add to in-memory list
    ↓
    return LeaveRequest
    ↓
leave_provider.dart:
    State 2: LeaveFormState(isSuccess: true)
    ↓ Trigger ref.listen callback
    ref.read(leaveListProvider.notifier).loadLeaveRequests()
    ↓ Refresh list
leave_form_page.dart:
    ↓ ref.listen detects isSuccess
    Navigator.pop(context, true)
    Show success snackbar
    ↓
leave_list_page.dart:
    if (result == true) refresh list
```

### Cross-Provider Communication

**Key Pattern**: One provider refreshing another's data

In [`leave_provider.dart:84-87`](../lib/app/riverpod/providers/leave_provider.dart#L84-L87):

```dart
// After creating leave, refresh the list
ref.read(leaveListProvider.notifier).loadLeaveRequests();
```

**Flow**:

```
LeaveFormNotifier
    └→ Successfully creates leave
        └→ ref.read(leaveListProvider.notifier)
            └→ Gets LeaveListNotifier instance
                └→ Calls loadLeaveRequests()
                    └→ Updates LeaveListState
                        └→ LeaveListPage rebuilds automatically
```

---

## Riverpod Concepts

### 1. Provider Types

#### Provider (Immutable)

**Example**: [`auth_provider.dart:6-8`](../lib/app/riverpod/providers/auth_provider.dart#L6-L8)

```dart
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
```

**Use case**: Services, repositories, utilities (don't change)

#### StateNotifierProvider (Mutable State)

**Example**: [`auth_provider.dart:53-56`](../lib/app/riverpod/providers/auth_provider.dart#L53-L56)

```dart
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
```

**Use case**: Managing mutable state (auth, lists, forms)

### 2. Ref Methods

#### ref.watch()

**Purpose**: Subscribe to changes, widget rebuilds automatically

```dart
final authState = ref.watch(authNotifierProvider);
// Widget rebuilds when authState changes
```

#### ref.read()

**Purpose**: Read once, no subscription

```dart
await ref.read(authNotifierProvider.notifier).login(username, password);
// Just calls method, doesn't rebuild
```

#### ref.listen()

**Purpose**: Perform side effects on changes

```dart
ref.listen(leaveFormProvider, (previous, next) {
  if (next.isSuccess) {
    Navigator.pop(context);
  }
});
// Doesn't rebuild, just performs action
```

### 3. State Updates

**Immutable Pattern** ([`auth_state.dart:12-20`](../lib/app/states/auth_state.dart#L12-L20)):

```dart
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
```

**Usage**:

```dart
// ❌ Wrong: Mutating state
state.isLoading = true;

// ✅ Correct: Creating new state
state = state.copyWith(isLoading: true);
```

### 4. Provider Scope

All providers live in `ProviderScope` ([`main.dart:5-9`](../lib/main.dart#L5-L9)):

```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**ProviderScope**:

- Container that holds all provider instances
- Required at app root
- Can be overridden for testing

---

## File Structure

```
lib/
├── main.dart                          # App entry point with ProviderScope
└── app/
    ├── models/                        # Data models
    │   ├── leave_request.dart         # Leave request model with helpers
    │   └── (auth has no model, uses state only)
    │
    ├── services/                      # Business logic layer
    │   ├── auth_service.dart          # Auth operations (SharedPrefs)
    │   └── leave_service.dart         # Leave CRUD operations
    │
    ├── states/                        # State models
    │   ├── auth_state.dart            # Authentication state
    │   └── leave_state.dart           # Leave list & form states
    │
    ├── riverpod/
    │   └── providers/                 # Riverpod providers
    │       ├── auth_provider.dart     # Auth state management
    │       └── leave_provider.dart    # Leave state management
    │
    ├── pages/                         # UI screens
    │   ├── splash_screen.dart         # Initial screen, checks auth
    │   ├── login_page.dart            # Login form
    │   ├── home_page.dart             # Main dashboard with modules
    │   ├── leave_list_page.dart       # Leave requests list
    │   └── leave_form_page.dart       # Create/edit leave form
    │
    └── utils/                         # Utility functions
        ├── date_formatter.dart        # Date formatting utilities
        └── date_formatter_example.dart # Usage examples
```

---

## Data Flow Examples

### Example 1: User Logs In

```
1. User enters credentials in login_page.dart
   ↓
2. Taps login button → _handleLogin()
   ↓
3. Calls: ref.read(authNotifierProvider.notifier).login(username, password)
   ↓
4. auth_provider.dart: AuthNotifier.login()
   ├─ Sets: state = state.copyWith(isLoading: true)
   │  └→ login_page.dart rebuilds (watches provider)
   │     └→ Button shows loading indicator
   ├─ Calls: authService.login(username, password)
   │  └→ auth_service.dart: AuthService.login()
   │     ├─ Validates input
   │     ├─ Saves to SharedPreferences
   │     └─ Returns: true
   └─ Sets: state = state.copyWith(isLoading: false, isAuthenticated: true, username: username)
      └→ login_page.dart rebuilds again
         └→ Navigates to home_page.dart
```

### Example 2: Loading Leave Requests

```
1. leave_list_page.dart opens
   ↓
2. initState() → Future.microtask(() => seedDemoData())
   ↓
3. Calls: ref.read(leaveListProvider.notifier).seedDemoData(username)
   ↓
4. leave_provider.dart: LeaveListNotifier.seedDemoData()
   ├─ Calls: leaveService.seedDemoData(username)
   │  └→ leave_service.dart: LeaveService.seedDemoData()
   │     └─ Adds demo LeaveRequest objects to in-memory list
   └─ Calls: loadLeaveRequests()
      ├─ Sets: state = state.copyWith(isLoading: true)
      │  └→ leave_list_page.dart rebuilds
      │     └→ Shows: CircularProgressIndicator
      ├─ Calls: leaveService.getAllLeaveRequests()
      │  └→ Returns: List<LeaveRequest>
      └─ Sets: state = state.copyWith(isLoading: false, leaveRequests: list)
         └→ leave_list_page.dart rebuilds
            └→ Shows: ListView with cards
```

### Example 3: Creating New Leave Request

```
1. User fills form in leave_form_page.dart
   ↓
2. Taps submit button → _handleSubmit()
   ↓
3. Calls: ref.read(leaveFormProvider.notifier).createLeaveRequest(...)
   ↓
4. leave_provider.dart: LeaveFormNotifier.createLeaveRequest()
   ├─ Sets: state = state.copyWith(isLoading: true)
   │  └→ leave_form_page.dart rebuilds
   │     └→ Button shows loading indicator
   ├─ Validates date range
   ├─ Calls: leaveService.createLeaveRequest(...)
   │  └→ leave_service.dart: LeaveService.createLeaveRequest()
   │     ├─ Creates new LeaveRequest object
   │     ├─ Adds to in-memory list
   │     └─ Returns: LeaveRequest
   ├─ Sets: state = state.copyWith(isLoading: false, isSuccess: true)
   │  └→ leave_form_page.dart: ref.listen callback triggered
   │     ├─ Navigator.pop(context, true)
   │     └─ Shows success snackbar
   └─ Calls: ref.read(leaveListProvider.notifier).loadLeaveRequests()
      └→ Refreshes list in leave_list_page.dart
```

---

## Best Practices Demonstrated

### 1. Avoid Modifying Provider During Build

**Problem**: Cannot update provider state in `initState()` or `build()`

**Solution**: Use `Future.microtask()`

```dart
// ❌ Wrong
@override
void initState() {
  super.initState();
  ref.read(provider.notifier).loadData(); // Error!
}

// ✅ Correct
@override
void initState() {
  super.initState();
  Future.microtask(() => ref.read(provider.notifier).loadData());
}
```

**Files**:

- [`splash_screen.dart:17`](../lib/app/pages/splash_screen.dart#L17)
- [`leave_list_page.dart:20`](../lib/app/pages/leave_list_page.dart#L20)

### 2. Separate Read and Watch

**Use `ref.watch()` for reactive updates**:

```dart
final state = ref.watch(myProvider); // Rebuilds widget
```

**Use `ref.read()` for one-time actions**:

```dart
await ref.read(myProvider.notifier).doSomething(); // Just calls method
```

### 3. Use ref.listen for Side Effects

**Navigation and snackbars should use `ref.listen()`**:

```dart
ref.listen(leaveFormProvider, (previous, next) {
  if (next.isSuccess) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(/*...*/);
  }
});
```

**File**: [`leave_form_page.dart:60-75`](../lib/app/pages/leave_form_page.dart#L60-L75)

### 4. Cross-Provider Communication

**One provider can read another**:

```dart
class LeaveFormNotifier extends StateNotifier<LeaveFormState> {
  final Ref ref; // Store ref

  LeaveFormNotifier(this.leaveService, this.ref) : super(LeaveFormState());

  Future<bool> createLeaveRequest(...) async {
    // ... create logic

    // Refresh list provider
    ref.read(leaveListProvider.notifier).loadLeaveRequests();

    return true;
  }
}
```

**File**: [`leave_provider.dart:84-87`](../lib/app/riverpod/providers/leave_provider.dart#L84-L87)

### 5. Immutable State Pattern

**Always use `copyWith()` to update state**:

```dart
// Create new state, don't mutate
state = state.copyWith(
  isLoading: false,
  data: newData,
);
```

**Files**:

- [`auth_state.dart:12-20`](../lib/app/states/auth_state.dart#L12-L20)
- [`leave_state.dart:12-19`](../lib/app/states/leave_state.dart#L12-L19)

### 6. Loading States

**Every async operation should have loading state**:

```dart
Future<void> loadData() async {
  // 1. Start loading
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    // 2. Fetch data
    final data = await service.getData();

    // 3. Success state
    state = state.copyWith(isLoading: false, data: data);
  } catch (e) {
    // 4. Error state
    state = state.copyWith(isLoading: false, errorMessage: e.toString());
  }
}
```

---

## Conclusion

This Phase 1 demonstrates:

1. ✅ **Complete authentication flow** with Riverpod state management
2. ✅ **CRUD operations** for leave requests
3. ✅ **Cross-provider communication** (form updates list)
4. ✅ **Proper state transitions** with loading, success, and error states
5. ✅ **Side effects handling** with `ref.listen()`
6. ✅ **Separation of concerns** across layers
7. ✅ **Clean architecture** with clear file structure

### Key Takeaways

- **Riverpod providers** hold and manage state
- **StateNotifier** handles state mutations
- **ref.watch()** for reactive UI updates
- **ref.read()** for one-time actions
- **ref.listen()** for side effects
- **State must be immutable** - always use `copyWith()`
- **Future.microtask()** to avoid build errors

### Next Steps

Phase 2 could include:

- API integration (replacing in-memory storage)
- Advanced state management patterns
- Error handling improvements
- Offline support
- More complex UI flows
