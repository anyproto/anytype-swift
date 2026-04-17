import Foundation
import SwiftUI
import AnytypeCore
import Services

// Channel-pin / favorite cases (IOS-5864 Task 10):
// Associated values mean `WidgetMenuItem` can no longer use a raw `String` backing.
// `Hashable` is synthesized for the enum because every payload is `Hashable`, which
// preserves the existing `id: \.self` iteration in `ForEach` and the `!= .changeType`
// filter comparisons in `WidgetContainerViewModel`.
enum WidgetMenuItem: Hashable {
    case changeType
    case remove
    case removeSystemWidget // Temporary action for split unpin and delete system widget. Delete after migration
    case favorite(isFavorited: Bool)
    case channelPin(isPinned: Bool)
}

struct WidgetCommonActionsMenuView: View {

    let items: [WidgetMenuItem]
    let widgetBlockId: String
    let widgetObject: any BaseDocumentProtocol
    let homeState: HomeWidgetsState
    let output: (any CommonWidgetModuleOutput)?
    // Optional context needed by `.favorite(...)` / `.channelPin(...)` handlers.
    // Older call sites that only surface the legacy trio (changeType / remove /
    // removeSystemWidget) don't have to supply these — the new handlers early-return
    // when `targetObjectId` / `accountInfo` are missing so a misconfigured caller
    // never crashes (Task 10 defensive wiring).
    let targetObjectId: String?
    let accountInfo: AccountInfo?

    @StateObject private var model = WidgetCommonActionsMenuViewModel()

    init(
        items: [WidgetMenuItem],
        widgetBlockId: String,
        widgetObject: any BaseDocumentProtocol,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?,
        targetObjectId: String? = nil,
        accountInfo: AccountInfo? = nil
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
        case .remove:
            Button {
                // Fix animation glitch.
                // We should to finalize context menu transition to list and then delete object
                // If we find how customize context menu transition, this 🩼 can be deleted
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    model.provider.onDeleteWidgetTap(
                        widgetObject: widgetObject,
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
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
                guard let targetObjectId, let accountInfo else { return }
                model.provider.onFavoriteTap(
                    targetObjectId: targetObjectId,
                    accountInfo: accountInfo
                )
            } label: {
                Text(isFavorited ? Loc.unfavorite : Loc.favorite)
                Image(systemName: isFavorited ? "star.fill" : "star")
            }
        case let .channelPin(isPinned):
            // `widgetObject` here is the channel widgets document (`info.widgetsId`) —
            // the same document the `.remove` case operates on. See
            // `WidgetActionsViewCommonMenuProvider.onChannelPinTap` for the toggle logic.
            Button {
                guard let targetObjectId else { return }
                model.provider.onChannelPinTap(
                    targetObjectId: targetObjectId,
                    widgetObject: widgetObject
                )
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
