import Foundation
import SwiftUI

struct RecentCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let type: RecentWidgetType
    
    var body: some View {
        RecentCompactListWidgetSubmoduleInternalView(data: data, type: type)
            .id(data.widgetBlockId + type.rawValue)
    }
}

private struct RecentCompactListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: RecentWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, type: RecentWidgetType) {
        self.data = data
        self._model = StateObject(wrappedValue: RecentWidgetInternalViewModel(data: data, type: type))
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
