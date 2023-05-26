import Foundation
import SwiftUI

protocol HomeWidgetCommonAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView
}
