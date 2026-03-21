import ComposableArchitecture
import Foundation

@Reducer
public struct TodoListFeature {
    @ObservableState
    public struct State: Equatable {
        public var todos: [Todo] = []
        public var isLoading: Bool = false
        public var errorMessage: String? = nil
        public var newTodoTitle: String = ""

        public init(
            todos: [Todo] = [],
            isLoading: Bool = false,
            errorMessage: String? = nil,
            newTodoTitle: String = ""
        ) {
            self.todos = todos
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.newTodoTitle = newTodoTitle
        }
    }

    public enum Action: Equatable {
        case onAppear
        case todosLoaded([Todo])
        case todosLoadFailed
        case newTodoTitleChanged(String)
        case submitTapped
        case todoAdded(Todo)
        case todoAddFailed
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

            case let .newTodoTitleChanged(title):
                state.newTodoTitle = title
                return .none

            case .submitTapped:
                let title = state.newTodoTitle.trimmingCharacters(in: .whitespaces)
                guard !title.isEmpty else { return .none }
                return .run { [title] send in
                    do {
                        let todo = try await apiClient.createTodo(title)
                        await send(.todoAdded(todo))
                    } catch {
                        await send(.todoAddFailed)
                    }
                }

            case let .todoAdded(todo):
                state.todos.append(todo)
                state.newTodoTitle = ""
                return .none

            case .todoAddFailed:
                return .none
            }
        }
    }
}
