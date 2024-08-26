import Foundation
import SwiftUI
import Services

struct WidgetSubmoduleData {
    let widgetBlockId: String
    let widgetObject: any BaseDocumentProtocol
    let homeState: Binding<HomeWidgetsState>
    let workspaceInfo: AccountInfo
    let output: (any CommonWidgetModuleOutput)?
}
