import Foundation
import SwiftUI

enum WidgetMenuItem: String {
    case changeSource
    case changeType
    case remove
}

struct WidgetContainerView<Content: View, ContentVM: WidgetContainerContentViewModelProtocol>: View {
    
    @ObservedObject var model: WidgetContainerViewModel
    @ObservedObject var contentModel: ContentVM
    var content: Content
        
    var body: some View {
        LinkWidgetViewContainer(
            title: contentModel.name,
            description: contentModel.count,
            isExpanded: $model.isExpanded,
            isEditalbeMode: model.isEditState
        ) {
            content
        }
        .onAppear {
            contentModel.onAppear()
        }
        .onDisappear {
            contentModel.onDisappear()
        }
        .if(!model.isEditState) {
            $0.contextMenu {
                menuItems
            }
        }
        
    }
    
    private var menuItems: some View {
        Group {
            ForEach(contentModel.menuItems, id: \.self) {
                menuItemToView(item: $0)
            }
            Divider()
            Button(Loc.Widgets.Actions.editWidgets) {
                print("on tap")
            }
        }
    }
    
    private func menuItemToView(item: WidgetMenuItem) -> some View {
        switch item {
        case .changeSource:
            return Button(Loc.Widgets.Actions.changeSource) {
                print("on tap")
            }
        case .changeType:
            return Button(Loc.Widgets.Actions.changeWidgetType) {
                print("on tap")
            }
        case .remove:
            return Button(Loc.Widgets.Actions.removeWidget) {
                // Fix anumation glytch.
                // We should to finalize context menu transition to list and then delete object
                // If we find how customize context menu transition, this 🩼 can be delete it
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    model.onDeleteWidgetTap()
                }
            }
        }
    }
}
