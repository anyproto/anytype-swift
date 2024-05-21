import Foundation
import SwiftUI

struct WidgetSubmoduleData {
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let homeState: Binding<HomeWidgetsState>
    let output: CommonWidgetModuleOutput?
}
