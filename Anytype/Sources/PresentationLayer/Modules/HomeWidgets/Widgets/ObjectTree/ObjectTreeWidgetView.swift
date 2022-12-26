import Foundation
import SwiftUI

struct ObjectTreeWidgetView: View {
    
    @ObservedObject var model: ObjectTreeWidgetViewModel
        
    var body: some View {
        LinkWidgetViewContainer(title: model.name, isExpanded: $model.isEexpanded) {
            // Temporary content
            VStack(alignment: .leading) {
                Text("Content \(model.name)")
            }
            .onAppear {
                print("on appear \(model.name)")
            }
            .foregroundColor(.red)
        }
    }
}
