import Foundation
import SwiftUI
import BlocksModels

// TODO: Create common provider, provider assembly, output if all files will be the same
final class RecentWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let recentWidgetModuleAssembly: RecentWidgetModuleAssemblyProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        recentWidgetModuleAssembly: RecentWidgetModuleAssemblyProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.recentWidgetModuleAssembly = recentWidgetModuleAssembly
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return recentWidgetModuleAssembly.make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            output: output
        )
    }()
    
    var componentId: String {
        return widgetBlockId
    }
}
