import Foundation
import SwiftUI

struct FavoriteCommonListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    var body: some View {
        FavoriteCommonListWidgetSubmoduleInternalView(data: data, style: style)
            .id(data.widgetBlockId + style.rawValue)
    }
}

private struct FavoriteCommonListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    
    @StateObject private var model: FavoriteWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, style: ListWidgetStyle) {
        self.data = data
        self.style = style
        self._model = StateObject(wrappedValue: FavoriteWidgetInternalViewModel(data: data))
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
