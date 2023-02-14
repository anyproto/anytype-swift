import Foundation
import SwiftUI

struct ObjectTreeWidgetView: View {
    
    @ObservedObject var model: ObjectTreeWidgetViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(model.rows, id: \.rowId) {
                ObjectTreeWidgetRowView(model: $0)
            }
        }
        .onAppear {
            model.onAppearList()
        }
        .onDisappear {
            model.onDisappearList()
        }
    }
}
