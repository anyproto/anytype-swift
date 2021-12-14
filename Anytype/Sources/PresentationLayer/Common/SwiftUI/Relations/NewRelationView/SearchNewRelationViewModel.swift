import BlocksModels
import CoreGraphics

enum SearchNewRelationSectionType: Hashable, Identifiable {
    case createNewRelation
    case addFromLibriry([RelationMetadata])

    var id: Self { self }

    var headerName: String {
        switch self {
        case .createNewRelation:
            return ""
        case .addFromLibriry:
            return "Your library".localized
        }
    }
}

class SearchNewRelationViewModel: ObservableObject {
    @Published var searchData: [SearchNewRelationSectionType] = [.createNewRelation]
    var onSelect: (RelationMetadata) -> ()

    func search(text: String) {
        
    }

    init(onSelect: @escaping (RelationMetadata) -> ()) {
        self.onSelect = onSelect
    }
}
