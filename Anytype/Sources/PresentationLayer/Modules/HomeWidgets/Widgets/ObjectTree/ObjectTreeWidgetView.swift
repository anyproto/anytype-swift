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
        .contextMenu {
            menuItems
        }
    }
    
    private var menuItems: some View {
        Group {
            Button(Loc.Widgets.Actions.changeSource) {
                print("on tap")
            }
            Button(Loc.Widgets.Actions.changeWidgetType) {
                print("on tap")
            }
            Button(Loc.Widgets.Actions.removeWidget) {
                // Fix anumation glytch.
                // We should to finalize context menu transition to list and then delete object
                // If we find how customize context menu transition, this 🩼 can be delete it
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    model.onDeleteWidgetTap()
                }
            }
            Divider()
            Button(Loc.Widgets.Actions.editWidgets) {
                print("on tap")
            }
        }
    }
}
