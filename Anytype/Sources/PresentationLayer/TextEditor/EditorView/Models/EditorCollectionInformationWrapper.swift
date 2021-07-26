import BlocksModels

struct EditorCollectionInformationWrapper: Hashable {
    let info: BlockInformation
    
    public static func == (lhs: EditorCollectionInformationWrapper, rhs: EditorCollectionInformationWrapper) -> Bool {
        lhs.info.id == rhs.info.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(info.id)
    }
}
