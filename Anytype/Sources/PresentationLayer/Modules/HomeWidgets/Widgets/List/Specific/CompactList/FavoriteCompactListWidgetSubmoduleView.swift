import Foundation
import SwiftUI

struct FavoriteCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        FavoriteCompactListWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct FavoriteCompactListWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: FavoriteWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: FavoriteWidgetInternalViewModel(data: data))
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
