import Foundation
import SwiftUI

enum WidgetMenuItem: String {
    case addBelow
    case changeSource
    case changeType
    case remove
}

struct WidgetCommonActionsMenuView: View {
    
    let items: [WidgetMenuItem]
    let widgetBlockId: String
    let widgetObject: any BaseDocumentProtocol
    let homeState: HomeWidgetsState
    let output: (any CommonWidgetModuleOutput)?
    
    @StateObject private var model = WidgetCommonActionsMenuViewModel()
    
    var body: some View {
        ForEach(items, id: \.self) {
            menuItemToView(item: $0)
        }
    }
    
    @ViewBuilder
    private func menuItemToView(item: WidgetMenuItem) -> some View {
        switch item {
        case .addBelow:
            Button(Loc.Widgets.Actions.addBelow) {
                model.provider.onAddBelowTap(
                    widgetBlockId: widgetBlockId,
                    homeState: homeState,
                    output: output
                )
            }
        case .changeSource:
            Button(Loc.Widgets.Actions.changeSource) {
                model.provider.onChangeSourceTap(
                    widgetBlockId: widgetBlockId,
                    homeState: homeState,
                    output: output
                )
            }
        case .changeType:
            Button(Loc.Widgets.Actions.changeWidgetType) {
                model.provider.onChangeTypeTap(
                    widgetBlockId: widgetBlockId,
                    homeState: homeState,
                    output: output
                )
            }
        case .remove:
            Button(Loc.Widgets.Actions.removeWidget, role: .destructive) {
                // Fix animation glitch.
                // We should to finalize context menu transition to list and then delete object
                // If we find how customize context menu transition, this 🩼 can be deleted
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    model.provider.onDeleteWidgetTap(
                        widgetObject: widgetObject,
                        widgetBlockId: widgetBlockId,
                        homeState: homeState
                    )
                }
            }
        }
    }
}

private final class WidgetCommonActionsMenuViewModel: ObservableObject {
    // Simple way for inject di. Model is this case is not needed.
    @Injected(\.widgetActionsViewCommonMenuProvider)
    var provider: any WidgetActionsViewCommonMenuProviderProtocol
}
