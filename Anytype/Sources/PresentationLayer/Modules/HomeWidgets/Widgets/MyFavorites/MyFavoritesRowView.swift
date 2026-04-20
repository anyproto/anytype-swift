import Foundation
import SwiftUI
import Services
import AnytypeCore

struct MyFavoritesRowView: View {
    let row: MyFavoritesRowData
    let showDivider: Bool
    let accountInfo: AccountInfo
    /// Channel widgets document for this space (`info.widgetsId`). Passed through
    /// to `WidgetActionsViewCommonMenuProvider.onChannelPinTap` so it can toggle
    /// the pin against the correct document.
    let channelWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    /// Computed once at the ViewModel layer (`pinnedToChannelByObjectId`) so each
    /// row receives a plain Bool instead of opening its own subscription.
    let isPinnedToChannel: Bool

    var body: some View {
        Button {
            row.onTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: row.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(row.title, style: .bodySemibold)
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
                    objectId: row.objectId,
                    accountInfo: accountInfo,
                    channelWidgetsObject: channelWidgetsObject,
                    canManageChannelPins: canManageChannelPins,
                    isPinnedToChannel: isPinnedToChannel
                )
            }
        }
    }
}

/// Split out so the context menu's body does not re-compute when the outer row
/// redraws for unrelated reasons (spacing / divider).
private struct MyFavoritesRowContextMenu: View {
    let objectId: String
    let accountInfo: AccountInfo
    let channelWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    let isPinnedToChannel: Bool

    var body: some View {
        Button {
            provider.onFavoriteTap(
                targetObjectId: objectId,
                accountInfo: accountInfo
            )
        } label: {
            Text(Loc.unfavorite)
            Image(systemName: "star.fill")
        }

        if canManageChannelPins {
            Button {
                provider.onChannelPinTap(
                    targetObjectId: objectId,
                    widgetObject: channelWidgetsObject
                )
            } label: {
                Text(isPinnedToChannel ? Loc.unpinFromChannel : Loc.pinToChannel)
                Image(systemName: isPinnedToChannel ? "pin.slash" : "pin")
            }
        }
    }

    // Resolve DI once per menu render; no need to wrap the provider in an
    // `ObservableObject` (rows are transient; lifecycle churn would hurt).
    private var provider: any WidgetActionsViewCommonMenuProviderProtocol {
        Container.shared.widgetActionsViewCommonMenuProvider()
    }
}
