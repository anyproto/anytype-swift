import Services

struct ObjectVersionData: Identifiable, Hashable {
    let title: String
    let icon: ObjectIcon?
    let objectId: String
    let spaceId: String
    let versionId: String
    let isListType: Bool
    let canRestore: Bool
    
    var id: Int { hashValue }
}
