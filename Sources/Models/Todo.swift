import Foundation

public struct Todo: Equatable, Codable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var isComplete: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        isComplete: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.createdAt = createdAt
    }
}
