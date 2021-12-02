import BlocksModels

final class RelationEditingViewModelBuilder {
    
    private let objectId: BlockId
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(objectId: BlockId, delegate: TextRelationEditingViewModelDelegate?) {
        self.objectId = objectId
        self.delegate = delegate
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(relation: Relation) -> RelationEditingViewModelProtocol? {
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
        default:
            return nil
        }
    }
    
}
