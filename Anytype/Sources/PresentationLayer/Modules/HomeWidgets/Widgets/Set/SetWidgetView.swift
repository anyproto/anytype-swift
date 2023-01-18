import Foundation
import SwiftUI

struct SetWidgetView: View {
    
    @ObservedObject var model: SetWidgetViewModel
    
    var body: some View {
        LinkWidgetViewContainer(title: model.name, isExpanded: $model.isExpanded) {
            Text("set widget")
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
}
