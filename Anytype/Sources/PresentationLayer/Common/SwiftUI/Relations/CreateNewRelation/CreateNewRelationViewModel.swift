import BlocksModels
import Combine


class CreateNewRelationViewModel: ObservableObject, Dismissible {
    @Published var relationTypes: [RelationMetadata.Format]
    @Published var selectedType: RelationMetadata.Format = .longText

    let source: RelationSource
    let relationService: RelationsServiceProtocol
    var onSelect: (RelationMetadata) -> ()
    var onDismiss: () -> () = {}

    init(
        source: RelationSource,
        relationService: RelationsServiceProtocol,
        onSelect: @escaping (RelationMetadata) -> ()
    ) {
        self.source = source
        self.relationService = relationService
        self.onSelect = onSelect

        self.relationTypes = RelationMetadata.Format.allCases.filter { $0 != .shortText && $0 != .unrecognized }
    }

    func createRelation(_ relationName: String) {
        let relationMetatdata = RelationMetadata(
            key: "",
            name: relationName,
            format: selectedType,
            isHidden: false,
            isReadOnly: false,
            isMulti: false,
            selections: [],
            objectTypes: [],
            scope: .object,
            isBundled: false
        )

        if let relation = relationService.createRelation(source: source, relation: relationMetatdata) {
            onSelect(relation)
        }
    }
}
