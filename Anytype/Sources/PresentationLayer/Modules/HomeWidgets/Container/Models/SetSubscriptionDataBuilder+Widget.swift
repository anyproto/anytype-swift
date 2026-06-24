import Foundation
import Services

extension SetSubscriptionDataBuilderProtocol {
    func widgetSubscriptionData(
        widgetInfo: BlockWidgetInfo,
        setDocument: any SetDocumentProtocol,
        identifier: String,
        spaceType: SpaceType?
    ) -> SubscriptionData {
        let setSubData = SetSubscriptionData(
            identifier: identifier,
            document: setDocument,
            groupFilter: nil,
            currentPage: 1,
            numberOfRowsPerPage: widgetInfo.fixedLimit,
            collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
            objectOrderIds: setDocument.objectOrderIds(for: subscriptionId),
            spaceType: spaceType
        )
        return set(setSubData)
    }
}
