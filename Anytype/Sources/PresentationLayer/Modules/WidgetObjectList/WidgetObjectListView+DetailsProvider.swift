import Foundation
import SwiftUI

final class WidgetObjectListHostingController<Model: WidgetObjectListViewModelProtocol>:
    UIHostingController<WidgetObjectListView<Model>>, DocumentDetaisProvider {
    
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
