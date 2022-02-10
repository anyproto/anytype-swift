import BlocksModels

final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    init(delegate: TextRelationActionButtonViewModelDelegate?) {
        self.delegate = delegate
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(objectId: BlockId, relation: Relation) -> RelationDetailsViewModelProtocol? {
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
                selectedStatus: status.value,
                allStatuses: status.allOptions,
                relation: relation,
                service: RelationsService(objectId: objectId)
            )
        case .tag(let tag):
            return RelationOptionsViewModel(
                type: .tags(tag.allTags),
                selectedOptions: tag.selectedTags,
                relation: relation,
                service: RelationsService(objectId: objectId)
            )
        case .object(let object):
            return RelationOptionsViewModel(
                type: .objects,
                selectedOptions: object.selectedObjects,
                relation: relation,
                service: RelationsService(objectId: objectId)
            )
        case .file(let file):
            return RelationOptionsViewModel(
                type: .files,
                selectedOptions: file.files,
                relation: relation,
                service: RelationsService(objectId: objectId)
            )
        default:
            return nil
        }
    }
    
}
