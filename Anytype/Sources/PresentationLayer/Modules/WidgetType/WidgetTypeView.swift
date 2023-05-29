import Foundation
import SwiftUI
import BlocksModels

struct WidgetTypeView: View {
    
    @ObservedObject var model: WidgetTypeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: Loc.Widgets.Layout.Screen.title)
            ForEach(model.rows, id:\.self) {
                WidgetTypeRowView(model: $0)
            }
        }
    }
}
