import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListCollectionsView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(output: WidgetObjectListCommonModuleOutput?) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            internalModel: WidgetObjectListCollectionsViewModel(),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
