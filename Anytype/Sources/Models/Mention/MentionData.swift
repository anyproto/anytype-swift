import BlocksModels

struct MentionData: Equatable, Hashable {
    let image: ObjectIconImage?
    let blockId: BlockId
    let isDeleted: Bool
    let isArchived: Bool
    
    static func noDetails(blockId: BlockId) -> MentionData {
        return MentionData(image: ObjectIconImage.staticImage(ImageName.ghost), blockId: blockId, isDeleted: true, isArchived: false)
    }
}

extension MentionData {
    init(details: ObjectDetails) {
        self.init(
            image: details.objectIconImage,
            blockId: details.id.value,
            isDeleted: details.isDeleted,
            isArchived: details.isArchived
        )
    }
}
