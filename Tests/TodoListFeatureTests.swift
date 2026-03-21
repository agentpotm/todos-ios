import ComposableArchitecture
import Foundation
import Testing

@testable import TodosApp

@MainActor
struct TodoListFeatureTests {
    @Test
    func onAppearFetchesTodos() async {
        let todos = [
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, title: "Buy groceries"),
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, title: "Write tests"),
        ]
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.fetchTodos = { todos }
        }
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.todosLoaded) {
            $0.isLoading = false
            $0.todos = todos
        }
    }

    @Test
    func onAppearWithEmptyTodosShowsEmptyState() async {
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.fetchTodos = { [] }
        }
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.todosLoaded) {
            $0.isLoading = false
            $0.todos = []
        }
    }

    @Test
    func onAppearFetchFailureShowsError() async {
        struct FetchError: Error {}
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.fetchTodos = { throw FetchError() }
        }
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.todosLoadFailed) {
            $0.isLoading = false
            $0.errorMessage = "Failed to load todos."
        }
    }

    @Test
    func submitTappedWithNonEmptyTitleAddsTodoAndClearsInput() async {
        let newTodo = Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, title: "Buy milk")
        let store = TestStore(
            initialState: TodoListFeature.State(newTodoTitle: "Buy milk")
        ) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.fetchTodos = { [] }
            $0.apiClient.createTodo = { _ in newTodo }
        }
        await store.send(.submitTapped)
        await store.receive(\.todoAdded) {
            $0.todos = [newTodo]
            $0.newTodoTitle = ""
        }
    }

    @Test
    func submitTappedWithEmptyTitleDoesNothing() async {
        let store = TestStore(
            initialState: TodoListFeature.State(newTodoTitle: "")
        ) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.fetchTodos = { [] }
            $0.apiClient.createTodo = { _ in Todo(title: "Should not be called") }
        }
        await store.send(.submitTapped)
        // No effects should fire — TestStore will fail if unexpected actions arrive
    }

    @Test
    func submitTappedWithWhitespaceOnlyTitleDoesNothing() async {
        let store = TestStore(
            initialState: TodoListFeature.State(newTodoTitle: "   ")
        ) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.fetchTodos = { [] }
            $0.apiClient.createTodo = { _ in Todo(title: "Should not be called") }
        }
        await store.send(.submitTapped)
    }

    @Test
    func titleChangedUpdatesState() async {
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.fetchTodos = { [] }
        }
        await store.send(.newTodoTitleChanged("New task")) {
            $0.newTodoTitle = "New task"
        }
    }

    @Test
    func deleteTodoRemovesItImmediately() async {
        let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let todos = [
            Todo(id: id1, title: "Buy groceries"),
            Todo(id: id2, title: "Write tests"),
        ]
        let store = TestStore(initialState: TodoListFeature.State(todos: todos)) {
            TodoListFeature()
        } withDependencies: {
            $0.apiClient.deleteTodo = { _ in }
        }
        await store.send(.deleteTodo(id: id1)) {
            $0.todos = [todos[1]]
        }
    }
}
