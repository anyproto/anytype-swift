import Foundation
import SwiftUI

struct AllObjectCommonListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    let type: AllObjectWidgetType
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleInternalView(data: data, style: style, type: type)
            .id(data.widgetBlockId + style.rawValue + type.rawValue)
    }
}

private struct AllObjectCommonListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    @StateObject private var model: AllObjectWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, style: ListWidgetStyle, type: AllObjectWidgetType) {
        self.data = data
        self.style = style
        self._model = StateObject(wrappedValue: AllObjectWidgetInternalViewModel(data: data, type: type))
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
