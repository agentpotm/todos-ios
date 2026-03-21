# todos-ios

The iOS (and macOS) client for the todos app. A SwiftUI app built with The Composable Architecture that lets users register, log in, manage their todos, and receive real-time updates.

## What this app does

- Register and log in with email and password
- View, add, edit, and delete todos
- Persist login across app launches using the iOS Keychain
- Receive live todo updates via WebSocket

---

## Tools and why we use them

| Tool | What it is | Why we use it |
|------|-----------|---------------|
| **Swift** | Apple's programming language | Type-safe, modern, and the standard language for iOS development. |
| **SwiftUI** | Apple's UI framework | Declarative UI — you describe what the screen should look like given the current state, and SwiftUI handles rendering and updates. Similar idea to React. |
| **Swift Package Manager (SPM)** | Dependency and build manager | The built-in tool for managing Swift dependencies and building packages. No Xcode project file needed. |
| **The Composable Architecture (TCA)** | State management library | Organises app logic into `Reducer`s that have explicit `State`, `Action`, and side-effect handling. Makes complex flows predictable and easy to test. Built by [Point-Free](https://www.pointfree.co). |
| **XCTest** | Test framework | Apple's built-in testing framework. TCA adds `TestStore` on top of it, which lets you assert on state changes action-by-action. |

---

## Architecture

The app uses **The Composable Architecture (TCA)**. If you're new to it, the key idea is:

- Every feature has a `State` struct (what data it holds), an `Action` enum (every event that can happen), and a `Reducer` (the function that handles actions and updates state or starts side effects).
- Features compose — the root `AppFeature` contains child features (`LoginFeature`, `TodoListFeature`).
- Side effects (network calls, Keychain reads) go through typed `Dependency` interfaces, making them easy to swap out in tests.

```
Sources/
├── App/
│   ├── AppFeature.swift          # Root reducer: decides whether to show auth or todo list
│   └── AppView.swift             # Root SwiftUI view
├── Features/
│   ├── Auth/
│   │   ├── LoginFeature.swift    # Login reducer: handles form input, API call, token storage
│   │   ├── LoginView.swift       # Login screen UI
│   │   ├── RegisterFeature.swift # Register reducer: handles registration flow
│   │   └── RegisterView.swift    # Register screen UI
│   └── Dashboard/
│       ├── TodoListFeature.swift # Main reducer: load, add, edit, delete todos + WebSocket
│       └── TodoListView.swift    # Todo list screen UI
├── Dependencies/
│   ├── APIClient.swift           # REST API abstraction (live + test implementations)
│   ├── KeychainClient.swift      # Secure token storage (live + test implementations)
│   └── WebSocketClient.swift     # WebSocket connection abstraction
└── Models/
    └── Todo.swift                # The Todo data model

Tests/
├── AppFeatureTests.swift         # Tests for root navigation logic
├── LoginFeatureTests.swift       # Tests for login flow
├── RegisterFeatureTests.swift    # Tests for registration flow
└── TodoListFeatureTests.swift    # Tests for todo CRUD and real-time updates
```

### How authentication works

On launch, `AppFeature` reads the Keychain via `KeychainClient`. If a token is found, the app goes straight to the todo list. If not, the login screen is shown. On successful login, the token is saved to the Keychain via `KeychainClient` and the app switches to the todo list. On logout, the token is removed and the app returns to login.

### How the API works

All network calls go through the `APIClient` dependency. This is a struct of closures (one per operation: `fetchTodos`, `createTodo`, etc.). In production the `liveValue` makes real HTTP requests. In tests the `testValue` (or a custom override) returns controlled data without hitting the network.

### How real-time updates work

`TodoListFeature` uses `WebSocketClient` to maintain a live connection to the backend. The backend sends events like `{ type: "todo:created", payload: {...} }` whenever any session modifies a todo. The reducer handles these events to update local state — no refetch needed.

---

## Prerequisites

- **macOS 13 or later**
- **Xcode 15 or later** — [download from the Mac App Store](https://apps.apple.com/app/xcode/id497799835)
- **Swift 5.9** (included with Xcode 15)

Check your Swift version:
```bash
swift --version   # should print Swift 5.9.x or later
```

You also need the **backend running on localhost:3000** — see the todos-backend README.

---

## Setup

```bash
# Fetch all Swift package dependencies
swift package resolve
```

That's it. Swift Package Manager downloads all dependencies automatically.

---

## Building and running

This is a Swift package, not a standalone `.xcodeproj`. To run it:

**From the command line:**
```bash
swift build          # Compile the package
swift test           # Build and run all tests
```

**From Xcode:**
```bash
open Package.swift   # Opens the package in Xcode
```

In Xcode, select a simulator and press ▶ to run. The app target is `TodosApp`.

> **Note:** The package is currently a library product — it's designed to be integrated into a host app or run via Xcode's package runner. A standalone runnable `@main` entry point has not been added yet.

---

## Commands

| Command | What it does |
|---------|-------------|
| `swift build` | Compile the package |
| `swift test` | Run all tests |
| `swift package resolve` | Download/update dependencies |
| `swift package clean` | Delete the build cache |
| `open Package.swift` | Open in Xcode |

---

## Environment / configuration

The backend URL is configured inside `APIClient.swift` in the `liveValue`. For local development it points to `http://localhost:3000`. To change the backend URL for a different environment, update this value before building.

There is no `.env` file — configuration is compiled into the binary.

---

## Tests

```bash
swift test
```

Tests use **TCA's `TestStore`**, which lets you dispatch actions and assert the exact state changes they produce, step by step. For example:

```swift
let store = TestStore(initialState: LoginFeature.State()) {
    LoginFeature()
} withDependencies: {
    $0.apiClient.login = { _, _ in "test-token" }  // override the real API
}

await store.send(.emailChanged("user@example.com")) {
    $0.email = "user@example.com"
}
```

This style of testing verifies business logic without a UI or a real network connection.

---

## Contributing

### Step-by-step workflow

1. **Read the spec** in [todos-product](https://github.com/agentpotm/todos-product) under `specs/` — it defines exactly what the feature must do
2. **Branch**: `git checkout -b feat/ios/<spec-name>`
3. **Add or update the `Feature` files** — keep `State`, `Action`, and the reducer in the `Feature` file; keep SwiftUI views in the `View` file
4. **Write tests** in the `Tests/` folder using `TestStore`
5. **Run `swift test`** — must pass with zero failures before pushing
6. **Push and open a PR** titled `feat(ios): <spec-name>`, referencing the spec

### Definition of done

- [ ] All spec acceptance criteria work on simulator
- [ ] Tests written and passing (`swift test`)
- [ ] No build warnings treated as errors
- [ ] PR references the spec

### Code conventions

- One feature = one `Feature` file + one `View` file
- Side effects (network, Keychain, WebSocket) always go through a `Dependency` — never call `URLSession` or Keychain APIs directly in a reducer
- State must be `Equatable` — required by TCA's testing infrastructure
- Test with `TestStore`, not by instantiating reducers directly
