import Foundation
import Services

protocol SetObjectWidgetOrderHelperProtocol: AnyObject {
    func reorder(
        setDocument: any SetDocumentProtocol,
        subscriptionStorage: any SubscriptionStorageProtocol,
        details: [ObjectDetails],
        onItemTap: @escaping @MainActor (_ details: ObjectDetails, _ allDetails: [ObjectDetails]) -> Void
    ) -> [SetContentViewItemConfiguration]
}

final class SetObjectWidgetOrderHelper: SetObjectWidgetOrderHelperProtocol {
    
    @Injected(\.setContentViewDataBuilder)
    private var setContentViewDataBuilder: any SetContentViewDataBuilderProtocol
    
    func reorder(
        setDocument: any SetDocumentProtocol,
        subscriptionStorage: any SubscriptionStorageProtocol,
        details: [ObjectDetails],
        onItemTap: @escaping @MainActor (_ details: ObjectDetails, _ allDetails: [ObjectDetails]) -> Void
    ) -> [SetContentViewItemConfiguration] {
        
        let sortedDetails: [ObjectDetails]
        let objectOrderIds = setDocument.objectOrderIds(for: "")
        if objectOrderIds.isNotEmpty {
            sortedDetails = details.reorderedStable(by: objectOrderIds, transform: { $0.id })
        } else {
            sortedDetails = details
        }
        
        return setContentViewDataBuilder.itemData(
            sortedDetails,
            dataView: setDocument.dataView,
            activeView: setDocument.activeView,
            viewRelationValueIsLocked: false,
            canEditIcon: setDocument.setPermissions.canEditSetObjectIcon,
            storage: subscriptionStorage.detailsStorage,
            spaceId: setDocument.spaceId,
            onItemTap: {
                onItemTap($0, sortedDetails)
            }
        )
    }
}
