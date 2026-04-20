import Foundation
import SwiftUI
import AnytypeCore
import Services

// Matches the context-menu transition-to-list animation so delete / unpin actions
// don't glitch mid-animation. Used by `.removeSystemWidget` and `.channelPin`.
private let menuDismissAnimationDelay: TimeInterval = 0.7

enum WidgetMenuItem: Hashable {
    case changeType
    case removeSystemWidget
    case favorite(isFavorited: Bool)
    case channelPin(isPinned: Bool)
}

struct WidgetCommonActionsMenuView: View {

    let items: [WidgetMenuItem]
    let widgetBlockId: String
    let widgetObject: any BaseDocumentProtocol
    let homeState: HomeWidgetsState
    let output: (any CommonWidgetModuleOutput)?
    /// `nil` for library widgets (Bin / Objects / Tasks / …). `.favorite` and
    /// `.channelPin` items require this to be non-nil — the VM's `menuItems` only
    /// emits them when `targetObjectId != nil`.
    let targetObjectId: String?
    let accountInfo: AccountInfo

    @StateObject private var model = WidgetCommonActionsMenuViewModel()

    init(
        items: [WidgetMenuItem],
        widgetBlockId: String,
        widgetObject: any BaseDocumentProtocol,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?,
        targetObjectId: String?,
        accountInfo: AccountInfo
    ) {
        self.items = items
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.homeState = homeState
        self.output = output
        self.targetObjectId = targetObjectId
        self.accountInfo = accountInfo
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
        case .removeSystemWidget:
            Button(role: .destructive) {
                // Fix animation glitch.
                // We should to finalize context menu transition to list and then delete object
                // If we find how customize context menu transition, this 🩼 can be deleted
                DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                    model.provider.onDeleteWidgetTap(
                        widgetObject: widgetObject,
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
            // X24 star variants are not in the asset catalog (plan Addendum A); the SF
            // Symbol fallback mirrors `ObjectActionRow.menuIcon` — dedicated icons are a
            // design-system follow-up.
            Button {
                guard let targetObjectId else {
                    anytypeAssertionFailure(".favorite menu item emitted without targetObjectId")
                    return
                }
                model.provider.onFavoriteTap(
                    targetObjectId: targetObjectId,
                    accountInfo: accountInfo
                )
            } label: {
                Text(isFavorited ? Loc.unfavorite : Loc.favorite)
                Image(systemName: isFavorited ? "star.fill" : "star")
            }
        case let .channelPin(isPinned):
            // `widgetObject` here is the channel widgets document (`info.widgetsId`).
            // See `WidgetActionsViewCommonMenuProvider.onChannelPinTap` for the toggle
            // logic. This action replaced the old `.remove` / "Unpin" menu item —
            // channel pins are now permission-gated and bidirectional (pin or unpin).
            Button {
                guard let targetObjectId else {
                    anytypeAssertionFailure(".channelPin menu item emitted without targetObjectId")
                    return
                }
                // Match `menuDismissAnimationDelay` used by `.removeSystemWidget`: the
                // context menu's transition-to-list animation hasn't finished when the
                // tap fires. Without the delay, unpinning a row that's currently
                // animating produces a glitch.
                let provider = model.provider
                let widgetObject = widgetObject
                DispatchQueue.main.asyncAfter(deadline: .now() + menuDismissAnimationDelay) {
                    provider.onChannelPinTap(
                        targetObjectId: targetObjectId,
                        widgetObject: widgetObject
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
    // Simple way for inject di. Model is this case is not needed.
    @Injected(\.widgetActionsViewCommonMenuProvider)
    var provider: any WidgetActionsViewCommonMenuProviderProtocol
}
