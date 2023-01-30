import Foundation
import BlocksModels

final class WidgetTypeCreateObjectViewModel: WidgetTypeInternalViewModelProtocol {
    
    private let widgetObjectId: String
    private let objectDetails: ObjectDetails
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let onFinish: () -> Void
    
    init(
        widgetObjectId: String,
        objectDetails: ObjectDetails,
        blockWidgetService: BlockWidgetServiceProtocol,
        onFinish: @escaping () -> Void
    ) {
        self.widgetObjectId = widgetObjectId
        self.objectDetails = objectDetails
        self.blockWidgetService = blockWidgetService
        self.onFinish = onFinish
    }
    
    // MARK: - WidgetTypeInternalViewModelProtocol
    
    func onTap(layout: BlockWidget.Layout) {
        Task { @MainActor in
            try? await blockWidgetService.createWidgetBlock(
                contextId: widgetObjectId,
                info: BlockInformation.empty(content: .link(.empty(targetBlockID: objectDetails.id))),
                layout: layout
            )
            onFinish()
        }
    }
}
