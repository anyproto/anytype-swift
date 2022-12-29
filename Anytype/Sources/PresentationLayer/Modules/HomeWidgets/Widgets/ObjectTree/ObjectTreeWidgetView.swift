import Foundation
import SwiftUI

struct ObjectTreeWidgetView: View {
    
    @ObservedObject var model: ObjectTreeWidgetViewModel
        
    var body: some View {
        LinkWidgetViewContainer(title: model.name, isExpanded: $model.isExpanded) {
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
