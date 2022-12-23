import Foundation
import SwiftUI

struct ObjectLintWidgetView: View {
    
    @ObservedObject var model: ObjectLintWidgetViewModel
        
    var body: some View {
        LinkWidgetViewContainer(title: model.name, isExpanded: $model.isEexpanded) {
            // Temporary content
            VStack(alignment: .leading) {
                Text(model.name)
            }
            .onAppear {
                print("on appear \(model.name)")
            }
            .foregroundColor(.red)
        }
    }
    
    
}
