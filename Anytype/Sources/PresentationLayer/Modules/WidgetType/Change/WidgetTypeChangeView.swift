import Foundation
import SwiftUI

struct WidgetTypeChangeView: View {

    @State private var model: WidgetTypeChangeViewModel

    init(data: WidgetTypeChangeData) {
        _model = State(initialValue: WidgetTypeChangeViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Widgets.Layout.Screen.title)
            ForEach(model.rows, id:\.self) {
                WidgetTypeRowView(model: $0)
            }
        }
        .task {
            await model.startObserveDocument()
        }
        .fitPresentationDetents()
    }
}
