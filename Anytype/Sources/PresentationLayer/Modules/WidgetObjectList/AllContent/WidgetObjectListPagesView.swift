import Foundation
import SwiftUI

struct WidgetObjectListPagesView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            spaceId: spaceId,
            internalModel: WidgetObjectListAllContentViewModel(spaceId: spaceId, type: .pages),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: output
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
