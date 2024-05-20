import Foundation
import SwiftUI

struct RecentCommonListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let type: RecentWidgetType
    let style: ListWidgetStyle
    
    var body: some View {
        RecentCommonListWidgetSubmoduleInternalView(data: data, type: type, style: style)
            .id(data.widgetBlockId + type.rawValue + style.rawValue)
    }
}

private struct RecentCommonListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    @StateObject private var model: RecentWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, type: RecentWidgetType, style: ListWidgetStyle) {
        self.data = data
        self.style = style
        self._model = StateObject(wrappedValue: RecentWidgetInternalViewModel(data: data, type: type))
    }
    
    var body: some View {
        ListWidgetView(
            data: data,
            style: style,
            internalModel: model,
            internalHeaderModel: nil
        )
    }
}
