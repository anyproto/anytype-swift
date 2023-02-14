import Foundation
import SwiftUI

final class WidgetObjectListHostingController: UIHostingController<WidgetObjectListView>, DocumentDetaisProvider {
    
    private let model: WidgetObjectListViewModel
    
    init(model: WidgetObjectListViewModel, rootView: WidgetObjectListView) {
        self.model = model
        super.init(rootView: rootView)
    }
    
    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - DocumentDetaisProvider
    
    var screenData: EditorScreenData {
        EditorScreenData(pageId: "", type: model.editorViewType)
    }

    var documentTitle: String? {
        return model.title
    }

    var documentDescription: String? {
        return nil
    }
}
