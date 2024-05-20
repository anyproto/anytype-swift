import Foundation
import SwiftUI

struct CollectionsCommonListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    var body: some View {
        CollectionsCommonListWidgetSubmoduleInternalView(data: data, style: style)
            .id(data.widgetBlockId + style.rawValue)
    }
}

private struct CollectionsCommonListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    @StateObject private var model: CollectionsWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, style: ListWidgetStyle) {
        self.data = data
        self.style = style
        self._model = StateObject(wrappedValue: CollectionsWidgetInternalViewModel(data: data))
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
