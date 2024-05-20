import Foundation
import SwiftUI

struct SetsCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetsCompactListWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct SetsCompactListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: SetsWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: SetsWidgetInternalViewModel(data: data))
    }
    
    var body: some View {
        ListWidgetView(
            data: data,
            style: .compactList,
            internalModel: model,
            internalHeaderModel: nil
        )
    }
}
