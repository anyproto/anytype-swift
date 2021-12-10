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
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string,
                service: TextRelationEditingService(objectId: objectId, valueType: .text),
                delegate: delegate
            )
        case .number(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string,
                service: TextRelationEditingService(objectId: objectId, valueType: .number),
                delegate: delegate
            )
        case .phone(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string,
                service: TextRelationEditingService(objectId: objectId, valueType: .phone),
                delegate: delegate
            )
        case .email(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string,
                service: TextRelationEditingService(objectId: objectId, valueType: .email),
                delegate: delegate
            )
        case .url(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string,
                service: TextRelationEditingService(objectId: objectId, valueType: .url),
                delegate: delegate
            )
        case .date(let value):
            return DateRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                value: value,
                service: DetailsService(objectId: objectId)
            )
        case .status(let status):
            guard let metadata = metadata else { return nil }
            
            return StatusRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
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
