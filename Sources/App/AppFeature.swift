import ComposableArchitecture
import Foundation

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var login: LoginFeature.State = LoginFeature.State()
        public var todoList: TodoListFeature.State = TodoListFeature.State()
        public var isAuthenticated: Bool = false

        public init(isAuthenticated: Bool = false) {
            self.isAuthenticated = isAuthenticated
            self.login = LoginFeature.State(isLoggedIn: isAuthenticated)
        }
    }

    public enum Action {
        case onAppear
        case authenticationChanged(Bool)
        case login(LoginFeature.Action)
        case todoList(TodoListFeature.Action)
    }

    @Dependency(\.keychainClient) var keychainClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        Scope(state: \.todoList, action: \.todoList) {
            TodoListFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                let token = try? keychainClient.loadToken()
                if token != nil {
                    state.isAuthenticated = true
                    state.login.isLoggedIn = true
                }
                return .none

            case let .authenticationChanged(isAuthenticated):
                state.isAuthenticated = isAuthenticated
                return .none

            case .login(.loginSucceeded(_)):
                state.isAuthenticated = true
                return .none

            case .login(.logoutCompleted):
                state.isAuthenticated = false
                state.todoList = TodoListFeature.State()
                return .none

            case .login:
                return .none

            case .todoList:
                return .none
            }
        }
    }
}
