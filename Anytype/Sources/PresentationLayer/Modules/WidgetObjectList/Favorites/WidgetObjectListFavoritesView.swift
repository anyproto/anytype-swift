import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListFavoritesView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(homeObjectId: String, spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            spaceId: spaceId,
            internalModel: WidgetObjectListFavoritesViewModel(homeObjectId: homeObjectId, spaceId: spaceId),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
