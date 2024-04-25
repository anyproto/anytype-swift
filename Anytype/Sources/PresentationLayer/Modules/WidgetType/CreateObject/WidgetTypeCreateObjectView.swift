import Foundation
import SwiftUI

struct WidgetTypeCreateObjectView: View {
    
    @StateObject private var model: WidgetTypeCreateObjectViewModel
    
    init(data: WidgetTypeCreateData) {
        self._model = StateObject(wrappedValue: WidgetTypeCreateObjectViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Widgets.Layout.Screen.title)
            ForEach(model.rows, id:\.self) {
                WidgetTypeRowView(model: $0)
            }
        }
        .fitPresentationDetents()
    }
}
