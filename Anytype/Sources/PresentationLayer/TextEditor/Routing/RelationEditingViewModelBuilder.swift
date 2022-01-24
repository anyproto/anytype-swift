import BlocksModels

#warning("TODO R: - return VC instead of ViewModel")
final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(delegate: TextRelationEditingViewModelDelegate?) {
        self.delegate = delegate
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(objectId: BlockId, relation: Relation) -> RelationEditingViewModelProtocol? {
        switch relation {
        case .text(let text):
            return TextRelationDetailsViewModel(
                value: text.value ?? "",
                type: .text,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionButtonViewModel: nil
            )
        case .number(let number):
            return TextRelationDetailsViewModel(
                value: number.value ?? "",
                type: .number,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionButtonViewModel: nil
            )
        case .phone(let phone):
            return TextRelationDetailsViewModel(
                value: phone.value ?? "",
                type: .phone,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionButtonViewModel: TextRelationActionButtonViewModel(type: .phone, delegate: delegate)
            )
        case .email(let email):
            return TextRelationDetailsViewModel(
                value: email.value ?? "",
                type: .email,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionButtonViewModel: TextRelationActionButtonViewModel(type: .email, delegate: delegate)
            )
        case .url(let url):
            return TextRelationDetailsViewModel(
                value: url.value ?? "",
                type: .url,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionButtonViewModel: TextRelationActionButtonViewModel(type: .url, delegate: delegate)
            )
        case .date(let value):
            return DateRelationDetailsViewModel(
                value: value.value,
                relation: relation,
                service: RelationsService(objectId: objectId)
            )
        case .status(let status):
            return StatusRelationDetailsViewModel(
                relationKey: relation.id,
                relationName: relation.name,
                relationOptions: status.allOptions,
                selectedStatus: status.value,
                relationsService: RelationsService(objectId: objectId)
            )
        case .tag(let tag):
            return RelationOptionsViewModel(
                type: .tags(tag.allTags),
                title: tag.name,
                relationKey: tag.id,
                selectedOptions: tag.selectedTags,
                relationsService: RelationsService(objectId: objectId)
            )
        case .object(let object):
            return RelationOptionsViewModel(
                type: .objects,
                title: object.name,
                relationKey: object.id,
                selectedOptions: object.selectedObjects,
                relationsService: RelationsService(objectId: objectId)
            )
        case .file(let file):
            return RelationOptionsViewModel(
                type: .files,
                title: file.name,
                relationKey: file.id,
                selectedOptions: file.files,
                relationsService: RelationsService(objectId: objectId)
            )
        default:
            return nil
        }
    }
    
}
