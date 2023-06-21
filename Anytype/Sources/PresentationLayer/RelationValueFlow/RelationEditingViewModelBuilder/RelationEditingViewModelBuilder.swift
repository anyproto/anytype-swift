import Services
import SwiftUI

final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let searchService: SearchServiceProtocol
    private let systemURLService: SystemURLServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    private let bookmarkService: BookmarkServiceProtocol
    
    init(
        delegate: TextRelationActionButtonViewModelDelegate?,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        searchService: SearchServiceProtocol,
        systemURLService: SystemURLServiceProtocol,
        alertOpener: AlertOpenerProtocol,
        bookmarkService: BookmarkServiceProtocol
    ) {
        self.delegate = delegate
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.searchService = searchService
        self.systemURLService = systemURLService
        self.alertOpener = alertOpener
        self.bookmarkService = bookmarkService
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    func buildViewModel(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        onTap: @escaping (_ id: BlockId, _ viewType: EditorViewType) -> Void
    ) -> AnytypePopupViewModelProtocol? {
        switch relation {
        case .text(let text):
            return TextRelationDetailsViewModel(
                value: text.value ?? "",
                type: .text,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectDetails.id)),
                analyticsType: analyticsType
            )
        case .number(let number):
            return TextRelationDetailsViewModel(
                value: number.value ?? "",
                type: .number,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectDetails.id)),
                analyticsType: analyticsType
            )
        case .phone(let phone):
            return TextRelationDetailsViewModel(
                value: phone.value ?? "",
                type: .phone,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectDetails.id)),
                analyticsType: analyticsType,
                actionsViewModel: [
                    TextRelationURLActionViewModel(
                        type: .phone,
                        systemURLService: systemURLService,
                        delegate: delegate
                    ),
                    TextRelationCopyActionViewModel(
                        type: .phone,
                        alertOpener: alertOpener,
                        delegate: delegate
                    )
                ]
            )
        case .email(let email):
            return TextRelationDetailsViewModel(
                value: email.value ?? "",
                type: .email,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectDetails.id)),
                analyticsType: analyticsType,
                actionsViewModel: [
                    TextRelationURLActionViewModel(
                        type: .email,
                        systemURLService: systemURLService,
                        delegate: delegate
                    ),
                    TextRelationCopyActionViewModel(
                        type: .email,
                        alertOpener: alertOpener,
                        delegate: delegate
                    )
                ]
            )
        case .url(let url):
            let actions: [TextRelationActionViewModelProtocol?] = [
                TextRelationURLActionViewModel(
                    type: .url,
                    systemURLService: systemURLService,
                    delegate: delegate
                ),
                TextRelationCopyActionViewModel(
                    type: .url,
                    alertOpener: alertOpener,
                    delegate: delegate
                ),
                TextRelationReloadContentActionViewModel(
                    objectDetails: objectDetails,
                    relation: relation,
                    bookmarkService: bookmarkService,
                    alertOpener: alertOpener
                )
            ]
            return TextRelationDetailsViewModel(
                value: url.value ?? "",
                type: .url,
                relation: relation,
                service: TextRelationDetailsService(service: RelationsService(objectId: objectDetails.id)),
                analyticsType: analyticsType,
                actionsViewModel: actions.compactMap { $0 }
            )
        case .date(let value):
            return DateRelationDetailsViewModel(
                value: value.value,
                relation: relation,
                service: RelationsService(objectId: objectDetails.id),
                analyticsType: analyticsType
            )
        case .status(let status):
            return StatusRelationDetailsViewModel(
                selectedStatus: status.values.first,
                relation: relation,
                service: RelationsService(objectId: objectDetails.id),
                newSearchModuleAssembly: newSearchModuleAssembly,
                searchService: searchService,
                analyticsType: analyticsType
            )
        case .tag(let tag):
            return RelationOptionsListViewModel(
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
                searchModuleBuilder: TagsOptionsSearchModuleBuilder(
                    relationKey: relation.key,
                    newSearcModuleAssembly: newSearchModuleAssembly
                ),
                service: RelationsService(objectId: objectDetails.id),
                analyticsType: analyticsType
            )
        case .object(let object):
            return RelationOptionsListViewModel(
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
                searchModuleBuilder: ObjectsOptionsSearchModuleBuilder(
                    limitedObjectType: object.limitedObjectTypes,
                    newSearcModuleAssembly: newSearchModuleAssembly
                ),
                service: RelationsService(objectId: objectDetails.id),
                analyticsType: analyticsType
            )
        case .file(let file):
            return RelationOptionsListViewModel(
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
                searchModuleBuilder: FilesOptionsSearchModuleBuilder(newSearcModuleAssembly: newSearchModuleAssembly),
                service: RelationsService(objectId: objectDetails.id),
                analyticsType: analyticsType
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
