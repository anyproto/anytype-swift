import Foundation
import SwiftUI

struct FavoriteTreeWidgetsubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        FavoriteTreeWidgetsubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct FavoriteTreeWidgetsubmoduleInternalView: View {
    
    @StateObject private var model: FavoriteWidgetInternalViewModel
    let data: WidgetSubmoduleData
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: FavoriteWidgetInternalViewModel(data: data))
    }
    
    var body: some View {
        TreeWidgetView(
            data: data,
            internalModel: model
        )
    }
}
