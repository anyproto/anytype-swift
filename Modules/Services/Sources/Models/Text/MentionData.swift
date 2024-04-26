public struct MentionData: Equatable, Hashable {
    public let details: ObjectDetails
    public let blockId: BlockId
    public let isDeleted: Bool
    public let isArchived: Bool
    
    public static func noDetails(blockId: BlockId) -> MentionData {
        return MentionData(details: ObjectDetails.deleted, blockId: blockId, isDeleted: true, isArchived: false)
    }
}

extension MentionData {
    public init(details: ObjectDetails) {
        self.init(
            details: details,
            blockId: details.id,
            isDeleted: details.isDeleted,
            isArchived: details.isArchived
        )
    }
}
