import Services
import SwiftUI

final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let textRelationEditingService: TextRelationEditingServiceProtocol
    private let searchService: SearchServiceProtocol
    private let systemURLService: SystemURLServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private let relationsService: RelationsServiceProtocol
    
    init(
        delegate: TextRelationActionButtonViewModelDelegate?,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        textRelationEditingService: TextRelationEditingServiceProtocol,
        searchService: SearchServiceProtocol,
        systemURLService: SystemURLServiceProtocol,
        alertOpener: AlertOpenerProtocol,
        bookmarkService: BookmarkServiceProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.delegate = delegate
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.textRelationEditingService = textRelationEditingService
        self.searchService = searchService
        self.systemURLService = systemURLService
        self.alertOpener = alertOpener
        self.bookmarkService = bookmarkService
        self.relationsService = relationsService
    }
    
}

extension RelationEditingViewModelBuilder: RelationEditingViewModelBuilderProtocol {
    
    @MainActor
    func buildViewModel(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        onTap: @escaping (_ screenData: EditorScreenData) -> Void
    ) -> AnytypePopupViewModelProtocol? {
        switch relation {
        case .text(let text):
            return TextRelationDetailsViewModel(
                objectId: objectDetails.id,
                value: text.value ?? "",
                type: .text,
                relation: relation,
                service: textRelationEditingService,
                analyticsType: analyticsType
            )
        case .number(let number):
            return TextRelationDetailsViewModel(
                objectId: objectDetails.id,
                value: number.value ?? "",
                type: .number,
                relation: relation,
                service: textRelationEditingService,
                analyticsType: analyticsType
            )
        case .phone(let phone):
            return TextRelationDetailsViewModel(
                objectId: objectDetails.id,
                value: phone.value ?? "",
                type: .phone,
                relation: relation,
                service: textRelationEditingService,
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
                objectId: objectDetails.id,
                value: email.value ?? "",
                type: .email,
                relation: relation,
                service: textRelationEditingService,
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
                    relationKey: relation.key,
                    bookmarkService: bookmarkService,
                    alertOpener: alertOpener
                )
            ]
            return TextRelationDetailsViewModel(
                objectId: objectDetails.id,
                value: url.value ?? "",
                type: .url,
                relation: relation,
                service: textRelationEditingService,
                analyticsType: analyticsType,
                actionsViewModel: actions.compactMap { $0 }
            )
        case .date(let value):
            return DateRelationDetailsViewModel(
                details: objectDetails,
                value: value.value,
                relation: relation,
                service: relationsService,
                analyticsType: analyticsType
            )
        case .status(let status):
            return StatusRelationDetailsViewModel(
                details: objectDetails,
                selectedStatus: status.values.first,
                relation: relation,
                service: relationsService,
                newSearchModuleAssembly: newSearchModuleAssembly,
                searchService: searchService,
                analyticsType: analyticsType
            )
        case .tag(let tag):
            let style = RelationStyle.regular(allowMultiLine: false)
            return RelationOptionsListViewModel(
                details: objectDetails,
                selectedOptions: tag.selectedTags.map { tag in
                    ListRowConfiguration(
                        id: tag.id,
                        contentHash: tag.hashValue
                    ) {
                        TagRelationRowView(
                            config: TagView.Config(
                                text: tag.text,
                                textColor: tag.textColor,
                                backgroundColor: tag.backgroundColor,
                                textFont: style.font,
                                guidlines: style.tagViewGuidlines
                            )
                        )
                        .eraseToAnyView()
                    }
                },
                emptyOptionsPlaceholder: Constants.tagsOrFilesOptionsPlaceholder,
                relation: relation,
                searchModuleBuilder: TagsOptionsSearchModuleBuilder(
                    relationKey: relation.key,
                    newSearcModuleAssembly: newSearchModuleAssembly
                ),
                service: relationsService,
                analyticsType: analyticsType
            )
        case .object(let object):
            return RelationOptionsListViewModel(
                details: objectDetails,
                selectedOptions: object.selectedObjects.map { object in
                    ListRowConfiguration(
                        id: object.id,
                        contentHash: object.hashValue
                    ) {
                        RelationObjectsRowView(
                            object: object,
                            action: {
                                if let editorScreenData = object.editorScreenData {
                                    onTap(editorScreenData)
                                }
                            }
                        ).eraseToAnyView()
                    }
                },
                emptyOptionsPlaceholder: Constants.objectsOptionsPlaceholder,
                relation: relation,
                searchModuleBuilder: ObjectsOptionsSearchModuleBuilder(
                    limitedObjectType: object.limitedObjectTypes,
                    newSearcModuleAssembly: newSearchModuleAssembly
                ),
                service: relationsService,
                analyticsType: analyticsType
            )
        case .file(let file):
            return RelationOptionsListViewModel(
                details: objectDetails,
                selectedOptions: file.files.map { file in
                    ListRowConfiguration(
                        id: file.id,
                        contentHash: file.hashValue
                    ) {
                        RelationFilesRowView(
                            file: file,
                            action: { onTap(file.editorScreenData) }
                        ).eraseToAnyView()
                    }
                },
                emptyOptionsPlaceholder: Constants.tagsOrFilesOptionsPlaceholder,
                relation: relation,
                searchModuleBuilder: FilesOptionsSearchModuleBuilder(newSearcModuleAssembly: newSearchModuleAssembly),
                service: relationsService,
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
