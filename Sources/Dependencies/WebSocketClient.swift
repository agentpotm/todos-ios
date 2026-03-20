import ComposableArchitecture
import Foundation

public struct WebSocketClient: Sendable {
    public var connect: @Sendable (URL) async throws -> Void
    public var disconnect: @Sendable () async -> Void
    public var send: @Sendable (String) async throws -> Void
    public var receive: @Sendable () async throws -> AsyncStream<WebSocketMessage>
}

public enum WebSocketMessage: Equatable, Sendable {
    case text(String)
    case data(Data)
}

extension WebSocketClient: DependencyKey {
    public static let liveValue = WebSocketClient(
        connect: { _ in
            // TODO: Implement WebSocket connection
        },
        disconnect: {
            // TODO: Implement WebSocket disconnection
        },
        send: { _ in
            // TODO: Implement WebSocket send
        },
        receive: {
            AsyncStream { _ in }
        }
    )

    public static let testValue = WebSocketClient(
        connect: { _ in },
        disconnect: {},
        send: { _ in },
        receive: { AsyncStream { _ in } }
    )
}

extension DependencyValues {
    public var webSocketClient: WebSocketClient {
        get { self[WebSocketClient.self] }
        set { self[WebSocketClient.self] = newValue }
    }
}

public enum WebSocketError: Error {
    case connectionFailed
    case sendFailed
    case disconnected
}
