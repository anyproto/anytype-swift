import Foundation
import SwiftUI

struct SetsCommonListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    var body: some View {
        SetsCommonListWidgetSubmoduleInternalView(data: data, style: style)
            .id(data.widgetBlockId + style.rawValue)
    }
}

private struct SetsCommonListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    @StateObject private var model: SetsWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, style: ListWidgetStyle) {
        self.data = data
        self.style = style
        self._model = StateObject(wrappedValue: SetsWidgetInternalViewModel(data: data))
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
