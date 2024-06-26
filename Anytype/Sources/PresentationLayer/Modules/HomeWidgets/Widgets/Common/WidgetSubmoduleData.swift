import Foundation
import SwiftUI

struct WidgetSubmoduleData {
    let widgetBlockId: String
    let widgetObject: any BaseDocumentProtocol
    let homeState: Binding<HomeWidgetsState>
    let output: (any CommonWidgetModuleOutput)?
}
