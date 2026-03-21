import ComposableArchitecture
import Foundation

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var login: LoginFeature.State = LoginFeature.State()

        public var isAuthenticated: Bool {
            login.isLoggedIn
        }

        public init(isAuthenticated: Bool = false) {
            self.login = LoginFeature.State(isLoggedIn: isAuthenticated)
        }
    }

    public enum Action {
        case onAppear
        case login(LoginFeature.Action)
    }

    @Dependency(\.keychainClient) var keychainClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                let token = try? keychainClient.loadToken()
                if token != nil {
                    state.login.isLoggedIn = true
                }
                return .none
            case .login:
                return .none
            }
        }
    }
}
