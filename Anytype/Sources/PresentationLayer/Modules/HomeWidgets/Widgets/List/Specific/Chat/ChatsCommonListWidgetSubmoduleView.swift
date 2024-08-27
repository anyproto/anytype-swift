import Foundation
import SwiftUI

struct ChatsCommonListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    var body: some View {
        ChatsCommonListWidgetSubmoduleInternalView(data: data, style: style)
            .id(data.widgetBlockId + style.rawValue)
    }
}

private struct ChatsCommonListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    @StateObject private var model: ChatsWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, style: ListWidgetStyle) {
        self.data = data
        self.style = style
        self._model = StateObject(wrappedValue: ChatsWidgetInternalViewModel(data: data))
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
