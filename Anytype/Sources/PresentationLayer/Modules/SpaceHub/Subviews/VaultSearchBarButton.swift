import SwiftUI
import AnytypeCore

// The vault bottom bar with unified search on: a search-field-shaped button that
// pushes the search screen, sharing the row with the create-channel menu (the
// native iOS 26 bottom-toolbar arrangement). Deliberately not `.searchable` -
// activating the native search UI mid-push wrecks the navigation transition.
struct VaultSearchBottomBar: View {

    let onTapSearch: () -> Void
    let onTapCreatePersonalChannel: () -> Void
    let onTapCreateGroupChannel: () -> Void
    let onTapJoinViaQrCode: () -> Void

    var body: some View {
        GlassEffectContainerIOS26(spacing: 6) {
            HStack(spacing: 10) {
                searchButton
                if #available(iOS 26.0, *) {
                    createMenu
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var searchButton: some View {
        Button {
            onTapSearch()
        } label: {
            HStack(spacing: 8) {
                Image(asset: .X18.search)
                    .foregroundStyle(Color.Control.secondary)
                AnytypeText(Loc.search, style: .uxBodyRegular)
                    .foregroundStyle(Color.Text.secondary)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .barBackground
            .fixTappableArea()
        }
        .buttonStyle(.plain)
    }

    @available(iOS 26.0, *)
    private var createMenu: some View {
        Menu {
            CreateChannelMenuItems(
                onTapPersonal: { onTapCreatePersonalChannel() },
                onTapGroup: { onTapCreateGroupChannel() },
                onTapJoinQR: { onTapJoinViaQrCode() }
            )
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(Color.Control.primary)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.interactive(), in: .circle)
        }
    }
}

private extension View {
    @ViewBuilder
    var barBackground: some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            self
                .background(Color.Background.highlightedMedium)
                .clipShape(.capsule)
        }
    }
}
