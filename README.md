# Loyalty-Points-Service-iOS

SwiftUI + MVVM login component for the consultant assessment.

## What is included

- `LoginViewModel.swift` — `@MainActor` state orchestration and async login flow.
- `LoginState.swift` — validation, lockout, loading, error, and navigation state.
- `LoginView.swift` — minimal SwiftUI login screen with email/password, remember-me, error messaging, and disabled submit states.
- `AuthService.swift` — auth and token persistence protocols plus a `UserDefaults` token store.
- `NetworkMonitor.swift` — injectable network availability abstraction.
- `LoginViewModelTests.swift` — deterministic XCTest coverage for the six required component behaviours.

## Covered scenarios

1. Validation enables/disables the login button.
2. Successful login emits an authenticated navigation event.
3. Invalid credentials increment the failure count.
4. Three failed attempts lock the user out and prevent further service calls.
5. Offline state shows a message and avoids calling auth.
6. Remember-me persists the returned token.

## Run tests

Open the package in Xcode or run from a machine with Swift 5.9+:

```bash
swift test
```
