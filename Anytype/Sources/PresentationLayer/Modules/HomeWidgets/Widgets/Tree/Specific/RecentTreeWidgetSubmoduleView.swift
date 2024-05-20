import Foundation
import SwiftUI

struct RecentTreeWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let type: RecentWidgetType
    
    var body: some View {
        RecentTreeWidgetSubmoduleInternalView(data: data, type: type)
            .id(data.widgetBlockId + type.rawValue)
    }
}

private struct RecentTreeWidgetSubmoduleInternalView: View {
    
    @StateObject private var model: RecentWidgetInternalViewModel
    let data: WidgetSubmoduleData
    let type: RecentWidgetType
    
    init(
        data: WidgetSubmoduleData,
        type: RecentWidgetType
    ) {
        self.data = data
        self.type = type
        self._model = StateObject(wrappedValue: RecentWidgetInternalViewModel(data: data, type: type))
    }
    
    var body: some View {
        TreeWidgetView(
            data: data,
            internalModel: model
        )
    }
}
