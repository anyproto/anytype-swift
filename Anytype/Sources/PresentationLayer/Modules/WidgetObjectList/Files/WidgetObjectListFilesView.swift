import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListFilesView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init() {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            internalModel: WidgetObjectListFilesViewModel(),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: nil,
            isSheet: true
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
    }
}
