import Foundation
import SwiftUI

struct ObjectTreeWidgetView: View {
    
    @ObservedObject var model: ObjectTreeWidgetViewModel
        
    var body: some View {
        LinkWidgetViewContainer(title: model.name, isExpanded: $model.isEexpanded) {
            // Temporary content
            VStack(alignment: .leading) {
                Text("Tree content \(model.name)")
            }
            .onAppear {
                model.onAppear()
            }
            .onDisappear {
                model.onDisappear()
            }
            .foregroundColor(.red)
        }
    }
}
