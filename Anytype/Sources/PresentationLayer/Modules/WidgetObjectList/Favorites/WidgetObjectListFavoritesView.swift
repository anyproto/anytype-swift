import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListFavoritesView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(homeObjectId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            internalModel: WidgetObjectListFavoritesViewModel(homeObjectId: homeObjectId),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
