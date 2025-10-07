import Foundation
import SwiftUI

struct ObjectTreeWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        ObjectTreeWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct ObjectTreeWidgetSubmoduleInternalView: View {
    
    @StateObject private var model: ObjectWidgetInternalViewModel
    let data: WidgetSubmoduleData
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: ObjectWidgetInternalViewModel(data: data))
    }
    
    var body: some View {
        TreeWidgetView(
            data: data,
            internalModel: model
        )
        .task(priority: .high) {
            await model.startBlockSubscription()
        }
        .task(priority: .high) {
            await model.startTreeSubscription()
        }
        .task {
            await model.startInfoSubscription()
        }
    }
}
