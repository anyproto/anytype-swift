import Foundation
import SwiftUI

struct PinnedTreeWidgetsubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        PinnedTreeWidgetsubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct PinnedTreeWidgetsubmoduleInternalView: View {
    
    @StateObject private var model: PinnedWidgetInternalViewModel
    let data: WidgetSubmoduleData
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: PinnedWidgetInternalViewModel(data: data))
    }
    
    var body: some View {
        TreeWidgetView(
            data: data,
            internalModel: model
        )
    }
}
