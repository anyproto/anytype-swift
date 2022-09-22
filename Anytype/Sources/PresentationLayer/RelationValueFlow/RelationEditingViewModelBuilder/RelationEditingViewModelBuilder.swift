import BlocksModels
import SwiftUI

final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    init(delegate: TextRelationActionButtonViewModelDelegate?) {
        self.delegate = delegate
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(
        source: RelationSource,
        objectId: BlockId,
        relation: Relation,
        onTap: @escaping (_ id: BlockId, _ viewType: EditorViewType) -> Void
    ) -> AnytypePopupViewModelProtocol? {
        switch relation {
        case .text(let text):
            return TextRelationDetailsViewModel(
                value: text.value ?? "",
                type: .text,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId))
            )
        case .number(let number):
            return TextRelationDetailsViewModel(
                value: number.value ?? "",
                type: .number,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId))
            )
        case .phone(let phone):
            return TextRelationDetailsViewModel(
                value: phone.value ?? "",
                type: .phone,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionsViewModel: [
                    TextRelationURLActionViewModel(
                        type: .phone,
                        systemURLService: ServiceLocator.shared.systemURLService(),
                        delegate: delegate
                    ),
                    TextRelationCopyActionViewModel(
                        type: .phone,
                        alertOpener: ServiceLocator.shared.alertOpener(),
                        delegate: delegate
                    )
                ]
            )
        case .email(let email):
            return TextRelationDetailsViewModel(
                value: email.value ?? "",
                type: .email,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionsViewModel: [
                    TextRelationURLActionViewModel(
                        type: .email,
                        systemURLService: ServiceLocator.shared.systemURLService(),
                        delegate: delegate
                    ),
                    TextRelationCopyActionViewModel(
                        type: .email,
                        alertOpener: ServiceLocator.shared.alertOpener(),
                        delegate: delegate
                    )
                ]
            )
        case .url(let url):
            let actions: [TextRelationActionViewModelProtocol?] = [
                TextRelationURLActionViewModel(
                    type: .url,
                    systemURLService: ServiceLocator.shared.systemURLService(),
                    delegate: delegate
                ),
                TextRelationCopyActionViewModel(
                    type: .url,
                    alertOpener: ServiceLocator.shared.alertOpener(),
                    delegate: delegate
                ),
                TextRelationReloadContentActionViewModel(
                    objectId: objectId,
                    relation: relation,
                    bookmarkService: ServiceLocator.shared.bookmarkService(),
                    alertOpener: ServiceLocator.shared.alertOpener()
                )
            ]
            return TextRelationDetailsViewModel(
                value: url.value ?? "",
                type: .url,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectId)),
                actionsViewModel: actions.compactMap { $0 }
            )
        case .date(let value):
            return DateRelationDetailsViewModel(
                value: value.value,
                relation: relation,
                service: RelationsService(objectId: objectId)
            )
        case .status(let status):
            return StatusRelationDetailsViewModel(
                source: source,
                selectedStatus: status.values.first,
                allStatuses: status.allOptions,
                relation: relation,
                service: RelationsService(objectId: objectId)
            )
        case .tag(let tag):
            return RelationOptionsListViewModel(
                source: source,
                selectedOptions: tag.selectedTags.map { tag in
                    ListRowConfiguration(
                        id: tag.id,
                        contentHash: tag.hashValue
                    ) {
                        TagRelationRowView(
                            viewModel: TagView.Model(text: tag.text, textColor: tag.textColor, backgroundColor: tag.backgroundColor)
                        ).eraseToAnyView()
                    }
                },
                emptyOptionsPlaceholder: Constants.tagsOrFilesOptionsPlaceholder,
                relation: relation,
                searchModuleBuilder: TagsOptionsSearchModuleBuilder(allTags: tag.allTags),
                service: RelationsService(objectId: objectId)
            )
        case .object(let object):
            return RelationOptionsListViewModel(
                source: source,
                selectedOptions: object.selectedObjects.map { object in
                    ListRowConfiguration(
                        id: object.id,
                        contentHash: object.hashValue
                    ) {
                        RelationObjectsRowView(
                            object: object,
                            action: { onTap(object.id, object.editorViewType) }
                        ).eraseToAnyView()
                    }
                },
                emptyOptionsPlaceholder: Constants.objectsOptionsPlaceholder,
                relation: relation,
                searchModuleBuilder: ObjectsOptionsSearchModuleBuilder(limitedObjectType: object.limitedObjectTypes),
                service: RelationsService(objectId: objectId)
            )
        case .file(let file):
            return RelationOptionsListViewModel(
                source: source,
                selectedOptions: file.files.map { file in
                    ListRowConfiguration(
                        id: file.id,
                        contentHash: file.hashValue
                    ) {
                        RelationFilesRowView(
                            file: file,
                            action: { onTap(file.id, .page) }
                        ).eraseToAnyView()
                    }
                },
                emptyOptionsPlaceholder: Constants.tagsOrFilesOptionsPlaceholder,
                relation: relation,
                searchModuleBuilder: FilesOptionsSearchModuleBuilder(),
                service: RelationsService(objectId: objectId)
            )
        default:
            return nil
        }
    }
    
}

private extension RelationEditingViewModelBuilder {
    
    enum Constants {
        static let objectsOptionsPlaceholder = Loc.empty
        static let tagsOrFilesOptionsPlaceholder = Loc.noRelatedOptionsHere
    }
    
}
