import ComposableArchitecture
import Foundation

public struct APIClient: Sendable {
    public var fetchTodos: @Sendable () async throws -> [Todo]
    public var createTodo: @Sendable (String) async throws -> Todo
    public var updateTodo: @Sendable (Todo) async throws -> Todo
    public var deleteTodo: @Sendable (UUID) async throws -> Void
    public var register: @Sendable (String, String) async throws -> Void
}

extension APIClient: DependencyKey {
    public static let liveValue = APIClient(
        fetchTodos: {
            throw APIClientError.notImplemented
        },
        createTodo: { _ in
            throw APIClientError.notImplemented
        },
        updateTodo: { _ in
            throw APIClientError.notImplemented
        },
        deleteTodo: { _ in
            throw APIClientError.notImplemented
        },
        register: { _, _ in
            throw APIClientError.notImplemented
        }
    )

    public static let testValue = APIClient(
        fetchTodos: { [] },
        createTodo: { title in Todo(title: title) },
        updateTodo: { todo in todo },
        deleteTodo: { _ in },
        register: { _, _ in }
    )
}

extension DependencyValues {
    public var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

public enum APIClientError: Error {
    case notImplemented
    case networkError(Error)
    case decodingError(Error)
    case unauthorized
    case duplicateEmail
}
