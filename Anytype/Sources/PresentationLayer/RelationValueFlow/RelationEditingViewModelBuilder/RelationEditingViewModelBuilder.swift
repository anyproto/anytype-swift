import Services
import SwiftUI

final class RelationEditingViewModelBuilder {
    
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    @Injected(\.textRelationEditingService)
    private var textRelationEditingService: TextRelationEditingServiceProtocol
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    @Injected(\.relationsService)
    private var relationsService: RelationsServiceProtocol
    
    init(delegate: TextRelationActionButtonViewModelDelegate?) {
        self.delegate = delegate
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
                        delegate: delegate
                    ),
                    TextRelationCopyActionViewModel(
                        type: .phone,
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
                        delegate: delegate
                    ),
                    TextRelationCopyActionViewModel(
                        type: .email,
                        delegate: delegate
                    )
                ]
            )
        case .url(let url):
            let actions: [TextRelationActionViewModelProtocol?] = [
                TextRelationURLActionViewModel(
                    type: .url,
                    delegate: delegate
                ),
                TextRelationCopyActionViewModel(
                    type: .url,
                    delegate: delegate
                ),
                TextRelationReloadContentActionViewModel(
                    objectDetails: objectDetails,
                    relationKey: relation.key,
                    delegate: delegate
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
