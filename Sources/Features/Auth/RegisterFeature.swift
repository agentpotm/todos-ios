import ComposableArchitecture
import Foundation

@Reducer
public struct RegisterFeature {
    @ObservableState
    public struct State: Equatable {
        public var email: String = ""
        public var password: String = ""
        public var isLoading: Bool = false
        public var errorMessage: String? = nil
        public var isRegistered: Bool = false

        public init(
            email: String = "",
            password: String = "",
            isLoading: Bool = false,
            errorMessage: String? = nil,
            isRegistered: Bool = false
        ) {
            self.email = email
            self.password = password
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.isRegistered = isRegistered
        }
    }

    public enum Action: Equatable {
        case emailChanged(String)
        case passwordChanged(String)
        case registerButtonTapped
        case registerSucceeded
        case registerFailed(RegisterError)
        case dismissSuccess
    }

    public enum RegisterError: Error, Equatable {
        case duplicateEmail
        case networkError
        case unknown(String)
    }

    @Dependency(\.apiClient) var apiClient

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

            case .registerButtonTapped:
                guard state.password.count >= 8 else {
                    state.errorMessage = "Password must be at least 8 characters."
                    return .none
                }
                state.isLoading = true
                state.errorMessage = nil
                return .run { [email = state.email, password = state.password] send in
                    do {
                        try await apiClient.register(email, password)
                        await send(.registerSucceeded)
                    } catch APIClientError.duplicateEmail {
                        await send(.registerFailed(.duplicateEmail))
                    } catch {
                        await send(.registerFailed(.networkError))
                    }
                }

            case .registerSucceeded:
                state.isLoading = false
                state.isRegistered = true
                return .none

            case let .registerFailed(error):
                state.isLoading = false
                switch error {
                case .duplicateEmail:
                    state.errorMessage = "An account with this email already exists."
                case .networkError:
                    state.errorMessage = "Registration failed. Please try again."
                case let .unknown(message):
                    state.errorMessage = message
                }
                return .none

            case .dismissSuccess:
                state.isRegistered = false
                return .none
            }
        }
    }
}
