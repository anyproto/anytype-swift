import Services

extension ObjectTypeSearchViewModel {
    enum SectionType {
        case lists
        case objects
        case library
        
        var name: String {
            switch self {
            case .lists:
                Loc.lists
            case .objects:
                Loc.objects
            case .library:
                Loc.anytypeLibrary
            }
        }
    }
    
    struct SectionData: Identifiable {
        let section: SectionType
        let types: [ObjectType]
        
        var id: SectionType {
            section
        }
    }
    
    
    enum State {
        case searchResults([SectionData])
        case emptyScreen
    }
}
