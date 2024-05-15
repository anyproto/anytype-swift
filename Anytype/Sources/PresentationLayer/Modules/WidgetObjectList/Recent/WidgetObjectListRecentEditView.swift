import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListRecentEditView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(output: WidgetObjectListCommonModuleOutput?) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            internalModel: WidgetObjectListRecentViewModel(type: .recentEdit),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
