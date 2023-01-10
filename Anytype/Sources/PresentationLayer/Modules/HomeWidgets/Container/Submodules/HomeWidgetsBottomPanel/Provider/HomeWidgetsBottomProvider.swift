import Foundation
import SwiftUI

final class HomeWidgetsBottomProvider: HomeWidgetProviderProtocol {
    
    private let bottomModuleAssembly: HomeWidgetsBottomModuleAssemblyProtocol
    
    init(
        bottomModuleAssembly: HomeWidgetsBottomModuleAssemblyProtocol
    ) {
        self.bottomModuleAssembly = bottomModuleAssembly
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return bottomModuleAssembly.make()
    }()
    
    lazy var componentId: String = {
        return UUID().uuidString
    }()
}
