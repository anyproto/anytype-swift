import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListFilesView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            spaceId: spaceId,
            internalModel: WidgetObjectListFilesViewModel(spaceId: spaceId),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: nil,
            isSheet: true
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
