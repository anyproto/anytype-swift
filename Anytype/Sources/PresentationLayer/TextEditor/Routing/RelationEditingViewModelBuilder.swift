import BlocksModels

final class RelationEditingViewModelBuilder {
    
    private let document: BaseDocumentProtocol
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(document: BaseDocumentProtocol, delegate: TextRelationEditingViewModelDelegate?) {
        self.document = document
        self.delegate = delegate
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(relation: Relation) -> RelationEditingViewModelProtocol? {
        switch relation.value {
        case .text(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: document.objectId,
                    valueType: .text
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .number(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: document.objectId,
                    valueType: .number
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .phone(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: document.objectId,
                    valueType: .phone
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .email(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: document.objectId,
                    valueType: .email
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .url(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: document.objectId,
                    valueType: .url
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .date(let value):
            return DateRelationEditingViewModel(
                service: DetailsService(objectId: document.objectId),
                key: relation.id,
                value: value
            )
            
        case .status(let status):
            let relationMetadata = document.relationsStorage.relations.first { $0.key == relation.id }
            guard let relationMetadata = relationMetadata else {
                return nil
            }
            
            return StatusRelationEditingViewModel(
                relationOptions: relationMetadata.selections,
                selectedStatus: status,
                key: relation.id,
                service: DetailsService(objectId: document.objectId)
            )
        default:
            return nil
        }
    }
    
}
