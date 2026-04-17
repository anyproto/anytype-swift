import Foundation
import SwiftUI
import Services
import AnytypeCore

struct MyFavoritesRowView: View {
    let row: MyFavoritesViewModel.Row
    let showDivider: Bool
    let accountInfo: AccountInfo
    /// Channel widgets document for this space (`info.widgetsId`). Used by the
    /// Pin-to-channel / Unpin-from-channel context-menu item. The row reads the
    /// current pinned state from it reactively via `syncPublisher`.
    let channelWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    let onTap: (ObjectDetails) -> Void

    @State private var isPinnedToChannel: Bool = false

    var body: some View {
        Button {
            onTap(row.details)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: row.details.objectIconImage)
                    .frame(width: 20, height: 20)

                AnytypeText(row.details.pluralTitle, style: .bodySemibold)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
        .if(FeatureFlags.personalFavorites) {
            $0.contextMenu {
                // Favorite section of a favorites row always renders "Unfavorite".
                MyFavoritesRowContextMenu(
                    details: row.details,
                    accountInfo: accountInfo,
                    channelWidgetsObject: channelWidgetsObject,
                    canManageChannelPins: canManageChannelPins,
                    isPinnedToChannel: isPinnedToChannel
                )
            }
            .task {
                await observeChannelPinState()
            }
        }
    }

    /// Reacts to `syncPublisher` emissions on the channel widgets document so the
    /// menu label ("Pin to Channel" vs "Unpin from Channel") stays in sync with
    /// the shared pinned list without requiring a ViewModel.
    private func observeChannelPinState() async {
        for await _ in channelWidgetsObject.syncPublisher.values {
            let next = channelWidgetsObject.isPinnedToChannel(objectId: row.details.id)
            guard isPinnedToChannel != next else { continue }
            isPinnedToChannel = next
        }
    }
}

/// Split out so the context menu's body does not re-compute when the outer row
/// redraws for unrelated reasons (spacing / divider). Uses DI for the provider
/// the same way `WidgetCommonActionsMenuView` does.
private struct MyFavoritesRowContextMenu: View {
    let details: ObjectDetails
    let accountInfo: AccountInfo
    let channelWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    let isPinnedToChannel: Bool

    @StateObject private var model = Model()

    var body: some View {
        Button {
            model.provider.onFavoriteTap(
                targetObjectId: details.id,
                accountInfo: accountInfo
            )
        } label: {
            Text(Loc.unfavorite)
            Image(systemName: "star.fill")
        }

        if canManageChannelPins {
            Button {
                model.provider.onChannelPinTap(
                    targetObjectId: details.id,
                    widgetObject: channelWidgetsObject
                )
            } label: {
                Text(isPinnedToChannel ? Loc.unpinFromChannel : Loc.pinToChannel)
                Image(systemName: isPinnedToChannel ? "pin.slash" : "pin")
            }
        }
    }

    private final class Model: ObservableObject {
        @Injected(\.widgetActionsViewCommonMenuProvider)
        var provider: any WidgetActionsViewCommonMenuProviderProtocol
    }
}
