import BlocksModels

final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(delegate: TextRelationEditingViewModelDelegate?) {
        self.delegate = delegate
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(objectId: BlockId, relation: Relation, metadata: RelationMetadata?) -> RelationEditingViewModelProtocol? {
        switch relation {
        case .text(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string.value,
                service: TextRelationEditingService(objectId: objectId, valueType: .text),
                delegate: delegate
            )
        case .number(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string.value,
                service: TextRelationEditingService(objectId: objectId, valueType: .number),
                delegate: delegate
            )
        case .phone(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string.value,
                service: TextRelationEditingService(objectId: objectId, valueType: .phone),
                delegate: delegate
            )
        case .email(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string.value,
                service: TextRelationEditingService(objectId: objectId, valueType: .email),
                delegate: delegate
            )
        case .url(let string):
            return TextRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationValue: string.value,
                service: TextRelationEditingService(objectId: objectId, valueType: .url),
                delegate: delegate
            )
        case .date(let value):
            return DateRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                value: value.value,
                service: DetailsService(objectId: objectId)
            )
        case .status(let status):            
            return StatusRelationEditingViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationOptions: status.allOptions,
                selectedStatus: status.value,
                detailsService: DetailsService(objectId: objectId),
                relationsService: RelationsService(objectId: objectId)
            )
        default:
            return nil
        }
    }
    
}
