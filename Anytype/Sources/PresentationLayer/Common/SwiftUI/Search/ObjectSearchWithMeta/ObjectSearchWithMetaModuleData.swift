import Services

struct ObjectSearchWithMetaModuleData: Identifiable, Hashable {
    let spaceId: String
    let type: ObjectSearchWithMetaType
    let excludedObjectIds: [String]
    @EquatableNoop var onSelect: (ObjectDetails) -> Void
    
    var id: Int { hashValue }
}

enum ObjectSearchWithMetaType: String {
    case pages
    case lists
    
    var title: String {
        switch self {
        case .pages:
            Loc.Chat.Attach.Page.title
        case .lists:
            Loc.Chat.Attach.List.title
        }
    }

    var section: ObjectTypeSection {
        switch self {
        case .pages:
            return .pages
        case .lists:
            return .lists
        }
    }
    
    var objectTypesKeys: [ObjectTypeUniqueKey] {
        switch self {
        case .pages:
            return [ObjectTypeUniqueKey.page, ObjectTypeUniqueKey.note]
        case .lists:
            return [ObjectTypeUniqueKey.set, ObjectTypeUniqueKey.collection]
        }
    }
    
    func title(for key: ObjectTypeUniqueKey) -> String? {
        switch key {
        case ObjectTypeUniqueKey.page:
            return Loc.ObjectSearchWithMeta.Create.page
        case ObjectTypeUniqueKey.note:
            return Loc.ObjectSearchWithMeta.Create.note
        case ObjectTypeUniqueKey.set:
            return Loc.ObjectSearchWithMeta.Create.set
        case ObjectTypeUniqueKey.collection:
            return Loc.ObjectSearchWithMeta.Create.collection
        default:
            return nil
        }
    }
}
