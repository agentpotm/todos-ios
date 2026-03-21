import ComposableArchitecture
import SwiftUI

public struct TodoListView: View {
    let store: StoreOf<TodoListFeature>

    public init(store: StoreOf<TodoListFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("New todo", text: Binding(
                    get: { store.newTodoTitle },
                    set: { store.send(.newTodoTitleChanged($0)) }
                ))
                .textFieldStyle(.roundedBorder)
                Button("Add") {
                    store.send(.submitTapped)
                }
                .disabled(store.newTodoTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()

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
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
