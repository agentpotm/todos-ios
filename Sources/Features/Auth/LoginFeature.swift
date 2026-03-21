import ComposableArchitecture
import Foundation

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        public var email: String = ""
        public var password: String = ""
        public var isLoading: Bool = false
        public var errorMessage: String? = nil
        public var isLoggedIn: Bool = false

        public init(
            email: String = "",
            password: String = "",
            isLoading: Bool = false,
            errorMessage: String? = nil,
            isLoggedIn: Bool = false
        ) {
            self.email = email
            self.password = password
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.isLoggedIn = isLoggedIn
        }
    }

    public enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case loginSucceeded(String)
        case loginFailed(LoginError)
        case logoutButtonTapped
        case logoutCompleted
    }

    public enum LoginError: Error, Equatable {
        case invalidCredentials
        case networkError
        case unknown(String)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.keychainClient) var keychainClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                state.errorMessage = nil
                return .none

            case let .passwordChanged(password):
                state.password = password
                state.errorMessage = nil
                return .none

            case .loginButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [email = state.email, password = state.password] send in
                    do {
                        let token = try await apiClient.login(email, password)
                        await send(.loginSucceeded(token))
                    } catch APIClientError.unauthorized {
                        await send(.loginFailed(.invalidCredentials))
                    } catch {
                        await send(.loginFailed(.networkError))
                    }
                }

            case let .loginSucceeded(token):
                state.isLoading = false
                state.isLoggedIn = true
                return .run { _ in
                    try? keychainClient.saveToken(token)
                }

            case let .loginFailed(error):
                state.isLoading = false
                switch error {
                case .invalidCredentials:
                    state.errorMessage = "Invalid email or password."
                case .networkError:
                    state.errorMessage = "Login failed. Please try again."
                case let .unknown(message):
                    state.errorMessage = message
                }
                return .none

            case .logoutButtonTapped:
                state.isLoggedIn = false
                return .run { send in
                    try? keychainClient.deleteToken()
                    await send(.logoutCompleted)
                }

            case .logoutCompleted:
                return .none
            }
        }
    }
}
