import Foundation
import SwiftUI

struct SetObjectCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetObjectCompactListWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct SetObjectCompactListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: SetObjectWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: SetObjectWidgetInternalViewModel(data: data))
    }
    
    var body: some View {
        ListWidgetView(
            data: data,
            style: .compactList,
            internalModel: model,
            internalHeaderModel: model
        )
    }
}
