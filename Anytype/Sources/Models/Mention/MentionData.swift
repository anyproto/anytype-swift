import Services

struct MentionData: Equatable, Hashable {
    let image: Icon?
    let blockId: BlockId
    let isDeleted: Bool
    let isArchived: Bool
    
    static func noDetails(blockId: BlockId) -> MentionData {
        return MentionData(image: Icon.asset(.ghost), blockId: blockId, isDeleted: true, isArchived: false)
    }
}

extension MentionData {
    init(details: ObjectDetails) {
        self.init(
            image: details.objectIconImage,
            blockId: details.id,
            isDeleted: details.isDeleted,
            isArchived: details.isArchived
        )
    }
}
