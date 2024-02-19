import Services

extension ObjectTypeSearchViewModel {
    enum SectionType {
        case pins
        case lists
        case objects
        case library
        
        var name: String {
            switch self {
            case .pins:
                Loc.pinned
            case .lists:
                Loc.lists
            case .objects:
                Loc.objects
            case .library:
                Loc.anytypeLibrary
            }
        }
    }
    
    struct ObjectTypeData {
        let type: ObjectType
        let isDefault: Bool
    }
    
    struct SectionData: Identifiable {
        let section: SectionType
        let types: [ObjectTypeData]
        
        var id: SectionType {
            section
        }
    }
    
    
    enum State {
        case searchResults([SectionData])
        case emptyScreen
    }
}
