# Agent Guide: todos-ios

## What this repo is

The iOS client for the todos product. Implements user stories from the product spec repo at https://github.com/agentpotm/todos-product.

Always read the relevant spec(s) from todos-product before implementing a feature. The spec is the source of truth for acceptance criteria.

## Architecture

**The Composable Architecture (TCA)** by Point-Free. Every feature is a `Reducer` with `State`, `Action`, and a `body` using `Reduce` + effects.

```
App
├── AppFeature          (root reducer, navigation)
├── AuthFeature
│   ├── LoginFeature
│   └── RegisterFeature
├── DashboardFeature
│   ├── TodoListFeature
│   └── TodoItemFeature
└── SyncFeature         (WebSocket client, connection indicator)
```

## Stack

| Layer | Choice |
|-------|--------|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Architecture | TCA (`swift-composable-architecture` via SPM) |
| Networking | URLSession (async/await) |
| Real-time | URLSessionWebSocketTask |
| Auth storage | Keychain (custom `KeychainClient` dependency) |
| Testing | Swift Testing + TCA `TestStore` |
| Min target | iOS 17 |

## TCA Conventions

- Each feature has its own file: `XxxFeature.swift`
- Use `@Dependency` for all external services (API, keychain, WebSocket)
- Dependencies defined in `Sources/Dependencies/`
- `TestStore` for all reducer tests — no mocking the store
- Views are in `Sources/Features/Xxx/XxxView.swift`

## Project Structure

```
todos-ios/
├── Package.swift           (or Xcode project)
├── Sources/
│   ├── App/
│   │   ├── AppFeature.swift
│   │   └── AppView.swift
│   ├── Features/
│   │   ├── Auth/
│   │   ├── Dashboard/
│   │   └── Sync/
│   ├── Dependencies/
│   │   ├── APIClient.swift
│   │   ├── KeychainClient.swift
│   │   └── WebSocketClient.swift
│   └── Models/
│       └── Todo.swift
└── Tests/
```

## Workflow

1. Read the spec from todos-product for the story you're implementing
2. Only implement specs with `stage: ready`
3. Implement the feature as a TCA `Reducer`
4. Write `TestStore` tests covering the acceptance criteria
5. Open a PR — title format: `feat(ios): <spec-name>` (e.g. `feat(ios): auth/login`)
6. After PR is merged, update `specs/status.yml` in todos-product:
   `ios: { state: done, version: <spec_version> }`

## Definition of Done

- [ ] All acceptance criteria from the spec pass in simulator (iPhone, latest iOS)
- [ ] `TestStore` tests written and passing
- [ ] No compiler warnings
- [ ] PR references the spec (e.g. `Implements agentpotm/todos-product spec: auth/login`)
