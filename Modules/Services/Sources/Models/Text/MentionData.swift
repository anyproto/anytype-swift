import AnytypeCore

public struct MentionObject: Equatable, Hashable {
    public let details: ObjectDetails
    public var id: BlockId { details.id }

    
    public init(details: ObjectDetails) {
        self.details = details
    }
}

public extension MentionObject {
    static func == (lhs: MentionObject, rhs: MentionObject) -> Bool {
        lhs.details == rhs.details
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(details)
    }
}

extension MentionObject {
    public static func noDetails(blockId: BlockId) -> MentionObject {
        MentionObject(details: .init(id: blockId))
    }
}
