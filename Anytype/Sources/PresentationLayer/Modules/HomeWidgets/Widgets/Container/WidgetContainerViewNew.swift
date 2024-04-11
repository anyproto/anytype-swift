import Foundation
import SwiftUI

struct WidgetContainerViewNew<Content: View, MenuItems: View>: View {
    
    let title: String
    let icon: ImageAsset?
    @Binding var isExpanded: Bool
    @Binding var homeState: HomeWidgetsState
    let dragId: String?
    
    let showSwipeActionTitle: Bool
    let onHeaderTap: () -> Void
    let onCreateObjectTap: (() -> Void)?
    let removeTap: (() -> Void)?
    let content: Content
    let menuItems: MenuItems
    
    var body: some View {
        WidgetSwipeActionView(
            isEnable: onCreateObjectTap != nil && homeState.isReadWrite,
            showTitle: isExpanded,
            action: {
                if #available(iOS 17.0, *) {
                    WidgetSwipeTip().invalidate(reason: .actionPerformed)
                }
                onCreateObjectTap?()
            }
        ) {
            LinkWidgetViewContainer(
                title: title,
                icon: icon,
                isExpanded: $isExpanded,
                dragId: dragId,
                homeState: homeState,
                allowMenuContent: true,
                allowContent: Content.self != EmptyView.self,
                headerAction: {
                    onHeaderTap()
                },
                removeAction: removeTap,
                menu: {
                    menuItems
                },
                content: {
                    content
                }
            )
            .if(homeState.isReadWrite) {
                $0.contextMenu {
                    contextMenuItems
                }
            }
        }
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        if homeState.isReadWrite {
            menuItems
            Divider()
            Button(Loc.Widgets.Actions.editWidgets) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    AnytypeAnalytics.instance().logEditWidget()
                    homeState = .editWidgets
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
        }
    }
}
