import Foundation
import SwiftUI

struct WidgetObjectListBookmarksView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            spaceId: spaceId,
            internalModel: WidgetObjectListAllContentViewModel(spaceId: spaceId, type: .bookmarks),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
