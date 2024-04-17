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
                spaceId: objectDetails.spaceId,
                value: text.value ?? "",
                type: .text,
                relation: relation,
                service: textRelationEditingService,
                analyticsType: analyticsType
            )
        case .number(let number):
            return TextRelationDetailsViewModel(
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
                value: number.value ?? "",
                type: .number,
                relation: relation,
                service: textRelationEditingService,
                analyticsType: analyticsType
            )
        case .phone(let phone):
            return TextRelationDetailsViewModel(
                objectId: objectDetails.id,
                spaceId: objectDetails.spaceId,
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
                spaceId: objectDetails.spaceId,
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
                spaceId: objectDetails.spaceId,
                value: url.value ?? "",
                type: .url,
                relation: relation,
                service: textRelationEditingService,
                analyticsType: analyticsType,
                actionsViewModel: actions.compactMap { $0 }
            )
        default:
            return nil
        }
    }
    
}
