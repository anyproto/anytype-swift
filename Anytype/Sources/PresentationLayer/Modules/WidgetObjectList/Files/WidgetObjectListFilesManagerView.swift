import Foundation
import SwiftUI

// TODO: Refactoring module
struct WidgetObjectListFilesManagerView: View {
    
    @StateObject private var model: WidgetObjectListViewModel
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: WidgetObjectListViewModel(
            spaceId: spaceId,
            internalModel: WidgetObjectListFilesManagerViewModel(spaceId: spaceId),
            menuBuilder: WidgetObjectListMenuBuilder(),
            output: nil,
            isSheet: true
        ))
    }
    
    var body: some View {
        WidgetObjectListView(model: model)
            .pageNavigationHiddenBackButton(true)
    }
}
