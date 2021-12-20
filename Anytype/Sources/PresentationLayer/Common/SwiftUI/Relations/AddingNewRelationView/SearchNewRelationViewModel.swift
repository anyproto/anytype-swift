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

class SearchNewRelationViewModel: ObservableObject, Dismissible {
    let relationService: RelationsServiceProtocol
    @Published var searchData: [SearchNewRelationSectionType] = [.createNewRelation]
    var onSelect: (RelationMetadata) -> ()
    var onDismiss: () -> () = {}

    init(relationService: RelationsServiceProtocol, onSelect: @escaping (RelationMetadata) -> ()) {
        self.relationService = relationService
        self.onSelect = onSelect
    }

    func search(text: String) {
        let newSearchData = obtainAvailbaleRelationList()

        guard !text.isEmpty else {
            searchData = newSearchData
            return
        }

        newSearchData.forEach { section in
            guard case let .addFromLibriry(relationsMetadata) = section else { return }

            let filteredRelationsMetadata = relationsMetadata.filter { relationMetadata in
                relationMetadata.name.contains(text)
            }

            searchData = [.addFromLibriry(filteredRelationsMetadata)]
        }
    }

    func obtainAvailbaleRelationList() -> [SearchNewRelationSectionType] {
        let relatonsMetadata = relationService.availableRelations()?.filter {
            !$0.isHidden
        } ?? []
        return [.createNewRelation, .addFromLibriry(relatonsMetadata)]
    }
}
