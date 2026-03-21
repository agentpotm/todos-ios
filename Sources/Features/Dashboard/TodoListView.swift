import ComposableArchitecture
import SwiftUI

public struct TodoListView: View {
    let store: StoreOf<TodoListFeature>

    public init(store: StoreOf<TodoListFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.isLoading {
                ProgressView()
            } else if let errorMessage = store.errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                }
            } else if store.todos.isEmpty {
                VStack {
                    Text("No Todos")
                        .font(.headline)
                    Text("You have no todos yet.")
                        .foregroundStyle(.secondary)
                }
            } else {
                List(store.todos) { todo in
                    Text(todo.title)
                        .swipeActions {
                            Button(role: .destructive) {
                                store.send(.deleteTodo(id: todo.id))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("Todos")
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    NavigationStack {
        TodoListView(
            store: Store(
                initialState: TodoListFeature.State(
                    todos: [
                        Todo(title: "Buy groceries"),
                        Todo(title: "Write tests"),
                    ]
                )
            ) {
                TodoListFeature()
            }
        )
    }
}
