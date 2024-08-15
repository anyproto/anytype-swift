import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListRecentEditView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            spaceId: spaceId,
            internalModel: WidgetObjectListRecentViewModel(spaceId: spaceId, type: .recentEdit),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
