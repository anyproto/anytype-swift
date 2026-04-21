import Foundation
import SwiftUI
import AnytypeCore
import Services

// Matches the context-menu transition-to-list animation so delete / unpin actions
// don't glitch mid-animation. Used by `.removeSystemWidget` and `.channelPin`.
private let menuDismissAnimationDelay: TimeInterval = 0.7

enum WidgetMenuItem: Hashable {
    case changeType
    /// Legacy "Unpin" action for object widgets under `personalFavorites` flag-off.
    /// Under flag-on, `.channelPin` (bidirectional, owner-gated) replaces this.
    case remove
    case removeSystemWidget
    case favorite(isFavorited: Bool)
    case channelPin(isPinned: Bool)
}

struct WidgetCommonActionsMenuView: View {

    let items: [WidgetMenuItem]
    let widgetBlockId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    /// Per-user personal widgets document. `nil` when the personalFavorites flag
    /// is off; in that case `.favorite` items never appear (VM's `menuItems`
    /// filters them out).
    let personalWidgetsObject: (any BaseDocumentProtocol)?
    let homeState: HomeWidgetsState
    let output: (any CommonWidgetModuleOutput)?
    /// `nil` for library widgets (Bin / Objects / Tasks / …). `.favorite` and
    /// `.channelPin` items require this to be non-nil — the VM's `menuItems` only
    /// emits them when `targetObjectId != nil`.
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
                // Same delay rationale as `.removeSystemWidget`: wait for the context
                // menu's transition-to-list animation to finish before triggering the
                // unpin, or the row-removal animation glitches.
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
                // Fix animation glitch.
                // We should to finalize context menu transition to list and then delete object
                // If we find how customize context menu transition, this 🩼 can be deleted
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
            // X24 star variants are not in the asset catalog (plan Addendum A); the SF
            // Symbol fallback mirrors `ObjectActionRow.menuIcon` — dedicated icons are a
            // design-system follow-up.
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
            // See `WidgetActionsViewCommonMenuProvider.onChannelPinTap` for the toggle
            // logic. Under the `personalFavorites` flag, this replaces the legacy
            // `.remove` / "Unpin" menu item — channel pins become permission-gated and
            // bidirectional (pin or unpin). Flag-off keeps `.remove` for parity with
            // the pre-IOS-5864 behavior.
            Button {
                guard let targetObjectId else {
                    anytypeAssertionFailure(".channelPin menu item emitted without targetObjectId")
                    return
                }
                // Match `menuDismissAnimationDelay` used by `.removeSystemWidget`: the
                // context menu's transition-to-list animation hasn't finished when the
                // tap fires. Without the delay, unpinning a row that's currently
                // animating produces a glitch.
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
    // Simple way for inject di. Model is this case is not needed.
    @Injected(\.widgetActionsViewCommonMenuProvider)
    var provider: any WidgetActionsViewCommonMenuProviderProtocol
}
