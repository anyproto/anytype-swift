import Foundation
import SwiftUI

struct SetCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetCompactListWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct SetCompactListWidgetSubmoduleInternalView: View {
    
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
