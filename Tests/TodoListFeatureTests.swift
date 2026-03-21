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
}
