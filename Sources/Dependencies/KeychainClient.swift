import ComposableArchitecture
import Foundation

public struct KeychainClient: Sendable {
    public var saveToken: @Sendable (String) throws -> Void
    public var loadToken: @Sendable () throws -> String?
    public var deleteToken: @Sendable () throws -> Void
}

extension KeychainClient: DependencyKey {
    public static let liveValue = KeychainClient(
        saveToken: { _ in
            // TODO: Implement Keychain storage
        },
        loadToken: {
            // TODO: Implement Keychain retrieval
            return nil
        },
        deleteToken: {
            // TODO: Implement Keychain deletion
        }
    )

    public static let testValue = KeychainClient(
        saveToken: { _ in },
        loadToken: { nil },
        deleteToken: {}
    )
}

extension DependencyValues {
    public var keychainClient: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}

public enum KeychainError: Error {
    case saveFailure(OSStatus)
    case loadFailure(OSStatus)
    case deleteFailure(OSStatus)
    case itemNotFound
}
