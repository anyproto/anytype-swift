import Foundation
import SwiftUI

final class WidgetObjectListHostingController: UIHostingController<WidgetObjectListView>, DocumentDetaisProvider {
    
    // MARK: - DocumentDetaisProvider
    
    var screenData: EditorScreenData {
        EditorScreenData(pageId: "", type: .favorites)
    }

    var documentTitle: String? {
        return Loc.favorites
    }

    var documentDescription: String? {
        return nil
    }
}
