import Foundation
import SwiftUI
import BlocksModels

final class ObjectTreeWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    private let subscriptionService: SubscriptionsServiceProtocol
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        objectDetailsStorage: ObjectDetailsStorage,
        subscriptionService: SubscriptionsServiceProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    var view: AnyView {
        
        let subscriptionManager = ObjectTreeSubscriptionManager(
            subscriptionDataBuilder: ObjectTreeSubscriptionDataBuilder(),
            subscriptionService: subscriptionService
        )
        
        // TODO: Maybe add assembly for each widget
        let model = ObjectTreeWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            objectDetailsStorage: objectDetailsStorage,
            subscriptionManager: subscriptionManager
        )
        return ObjectTreeWidgetView(model: model).eraseToAnyView()
    }
    
    var componentId: String {
        return widgetBlockId
    }
}
