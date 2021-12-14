import BlocksModels

final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(delegate: TextRelationEditingViewModelDelegate?) {
        self.delegate = delegate
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(objectId: BlockId, relation: Relation, metadata: RelationMetadata?) -> RelationEditingViewModelProtocol? {
        switch relation.value {
        case .text(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: objectId,
                    valueType: .text
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .number(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: objectId,
                    valueType: .number
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .phone(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: objectId,
                    valueType: .phone
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .email(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: objectId,
                    valueType: .email
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .url(let string):
            return TextRelationEditingViewModel(
                service: TextRelationEditingService(
                    objectId: objectId,
                    valueType: .url
                ),
                key: relation.id,
                value: string,
                delegate: delegate
            )
        case .date(let value):
            return DateRelationEditingViewModel(
                service: DetailsService(objectId: objectId),
                key: relation.id,
                value: value
            )
            
        case .status(let status):
            guard let metadata = metadata else { return nil }
            
            return StatusRelationEditingViewModel(
                relationKey: relation.id,
                relationOptions: metadata.selections,
                selectedStatus: status,
                detailsService: DetailsService(objectId: objectId),
                relationsService: RelationsService(objectId: objectId)
            )
        default:
            return nil
        }
    }
    
}
