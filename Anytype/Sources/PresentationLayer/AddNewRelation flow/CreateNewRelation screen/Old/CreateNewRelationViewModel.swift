import BlocksModels
import Combine


class CreateNewRelationViewModel: ObservableObject, Dismissible {
    @Published var relationTypes: [RelationMetadata.Format]
    @Published var selectedType: RelationMetadata.Format = .object

    let relationService: RelationsServiceProtocol
    var onSelect: (RelationMetadata) -> ()
    var onDismiss: () -> () = {}

    init(
        relationService: RelationsServiceProtocol,
        onSelect: @escaping (RelationMetadata) -> ()
    ) {
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

        if let relation = relationService.createRelation(relation: relationMetatdata) {
            onSelect(relation)
        }
    }
}
