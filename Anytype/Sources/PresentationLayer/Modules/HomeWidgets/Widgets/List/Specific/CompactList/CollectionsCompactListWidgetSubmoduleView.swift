import Foundation
import SwiftUI

struct CollectionsCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        CollectionsCompactListWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct CollectionsCompactListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: CollectionsWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: CollectionsWidgetInternalViewModel(data: data))
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
