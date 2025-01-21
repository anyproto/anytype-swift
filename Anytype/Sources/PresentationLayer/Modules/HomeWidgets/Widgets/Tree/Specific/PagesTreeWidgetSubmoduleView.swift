import Foundation
import SwiftUI

struct PagesTreeWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        PagesTreeWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct PagesTreeWidgetSubmoduleInternalView: View {
    
    @StateObject private var model: AllObjectWidgetInternalViewModel
    let data: WidgetSubmoduleData
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: AllObjectWidgetInternalViewModel(data: data, type: .pages))
    }
    
    var body: some View {
        TreeWidgetView(
            data: data,
            internalModel: model
        )
    }
}
