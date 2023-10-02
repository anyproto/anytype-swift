import Foundation
import SwiftUI
import Services

struct WidgetTypeView: View {
    
    @StateObject var model: WidgetTypeViewModel
    
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
