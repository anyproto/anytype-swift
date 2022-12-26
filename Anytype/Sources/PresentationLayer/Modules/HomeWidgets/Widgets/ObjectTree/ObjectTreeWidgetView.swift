import Foundation
import SwiftUI

struct ObjectTreeWidgetView: View {
    
    @ObservedObject var model: ObjectTreeWidgetViewModel
        
    var body: some View {
        LinkWidgetViewContainer(title: model.name, isExpanded: $model.isEexpanded) {
            // Temporary content
            VStack(alignment: .leading) {
                Text("Tree content \(model.name)")
                Text("Widget id \(model.widgetBlockId)")
            }
            .foregroundColor(.red)
        }
        .onAppear {
            model.onAppear()
            print("ObjectTreeWidgetView onAppear \(model.widgetBlockId)")
        }
        .onDisappear {
            model.onDisappear()
            print("ObjectTreeWidgetView onDisappear \(model.widgetBlockId)")
        }
    }
}
