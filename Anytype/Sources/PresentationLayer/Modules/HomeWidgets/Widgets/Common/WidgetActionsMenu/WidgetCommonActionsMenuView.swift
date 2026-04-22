import Foundation
import SwiftUI
import AnytypeCore
import Services

enum WidgetMenuItem: Hashable {
    case changeType
    case remove
    case removeSystemWidget
    case favorite(isFavorited: Bool)
    case channelPin(isPinned: Bool)
}

struct WidgetCommonActionsMenuView: View {

    let items: [WidgetMenuItem]
    let widgetBlockId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: (any BaseDocumentProtocol)?
    let homeState: HomeWidgetsState
    let output: (any CommonWidgetModuleOutput)?
    let targetObjectId: String?

    @StateObject private var model = WidgetCommonActionsMenuViewModel()

    init(
        items: [WidgetMenuItem],
        widgetBlockId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: (any BaseDocumentProtocol)?,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?,
        targetObjectId: String?
    ) {
        self.items = items
        self.widgetBlockId = widgetBlockId
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
        self.homeState = homeState
        self.output = output
        self.targetObjectId = targetObjectId
    }

    var body: some View {
        ForEach(items, id: \.self) {
            menuItemToView(item: $0)
        }
    }

    @ViewBuilder
    private func menuItemToView(item: WidgetMenuItem) -> some View {
        switch item {
        case .changeType:
            Button {
                model.provider.onChangeTypeTap(
                    widgetBlockId: widgetBlockId,
                    homeState: homeState,
                    output: output
                )
            } label: {
                Text(Loc.Widgets.Actions.changeWidgetType)
                Image(systemName: "arrow.2.squarepath")
            }
        case .remove:
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                    model.provider.onDeleteWidgetTap(
                        widgetObject: channelWidgetsObject,
                        widgetBlockId: widgetBlockId,
                        homeState: homeState,
                        output: output
                    )
                }
            } label: {
                Text(Loc.unpin)
                Image(systemName: "pin.slash")
            }
        case .removeSystemWidget:
            Button(role: .destructive) {
                DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                    model.provider.onDeleteWidgetTap(
                        widgetObject: channelWidgetsObject,
                        widgetBlockId: widgetBlockId,
                        homeState: homeState,
                        output: output
                    )
                }
            } label: {
                Text(Loc.Widgets.Actions.removeWidget)
                Image(systemName: "trash")

            }
        case let .favorite(isFavorited):
            // TODO: swap SF Symbol fallback for X24 star assets once design adds them.
            Button {
                guard let targetObjectId else {
                    anytypeAssertionFailure(".favorite menu item emitted without targetObjectId")
                    return
                }
                guard let personalWidgetsObject else {
                    anytypeAssertionFailure(".favorite menu item emitted without personalWidgetsObject")
                    return
                }
                model.provider.onFavoriteTap(
                    targetObjectId: targetObjectId,
                    personalWidgetsObject: personalWidgetsObject
                )
            } label: {
                Text(isFavorited ? Loc.unfavorite : Loc.favorite)
                Image(systemName: isFavorited ? "star.fill" : "star")
            }
        case let .channelPin(isPinned):
            Button {
                guard let targetObjectId else {
                    anytypeAssertionFailure(".channelPin menu item emitted without targetObjectId")
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                    model.provider.onChannelPinTap(
                        targetObjectId: targetObjectId,
                        channelWidgetsObject: channelWidgetsObject
                    )
                }
            } label: {
                Text(isPinned ? Loc.unpinFromChannel : Loc.pinToChannel)
                Image(systemName: isPinned ? "pin.slash" : "pin")
            }
        }
    }
}

private final class WidgetCommonActionsMenuViewModel: ObservableObject {
    @Injected(\.widgetActionsViewCommonMenuProvider)
    var provider: any WidgetActionsViewCommonMenuProviderProtocol
}
