import ComposableArchitecture
import Foundation

@Reducer
public struct TodoListFeature {
    @ObservableState
    public struct State: Equatable {
        public var todos: [Todo] = []
        public var isLoading: Bool = false
        public var errorMessage: String? = nil

        public init(
            todos: [Todo] = [],
            isLoading: Bool = false,
            errorMessage: String? = nil
        ) {
            self.todos = todos
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }
    }

    public enum Action: Equatable {
        case onAppear
        case todosLoaded([Todo])
        case todosLoadFailed
        case deleteTodo(id: UUID)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let todos = try await apiClient.fetchTodos()
                        await send(.todosLoaded(todos))
                    } catch {
                        await send(.todosLoadFailed)
                    }
                }

            case let .todosLoaded(todos):
                state.isLoading = false
                state.todos = todos
                return .none

            case .todosLoadFailed:
                state.isLoading = false
                state.errorMessage = "Failed to load todos."
                return .none

            case let .deleteTodo(id):
                state.todos.removeAll { $0.id == id }
                return .run { _ in
                    try? await apiClient.deleteTodo(id)
                }
            }
        }
    }
}
