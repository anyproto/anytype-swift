import Foundation
import SwiftUI

struct SetObjectCommonListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    var body: some View {
        SetObjectCommonListWidgetSubmoduleInternalView(data: data, style: style)
            .id(data.widgetBlockId + style.rawValue)
    }
}

private struct SetObjectCommonListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    @StateObject private var model: SetObjectWidgetLegacyInternalViewModel
    
    init(data: WidgetSubmoduleData, style: ListWidgetStyle) {
        self.data = data
        self.style = style
        self._model = StateObject(wrappedValue: SetObjectWidgetLegacyInternalViewModel(data: data))
    }
    
    var body: some View {
        ListWidgetView(
            data: data,
            style: style,
            internalModel: model,
            internalHeaderModel: model
        )
    }
}
