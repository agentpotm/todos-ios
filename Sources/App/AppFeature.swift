import ComposableArchitecture
import Foundation

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var isAuthenticated: Bool = false

        public init(isAuthenticated: Bool = false) {
            self.isAuthenticated = isAuthenticated
        }
    }

    public enum Action {
        case onAppear
        case authenticationChanged(Bool)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .authenticationChanged(isAuthenticated):
                state.isAuthenticated = isAuthenticated
                return .none
            }
        }
    }
}
