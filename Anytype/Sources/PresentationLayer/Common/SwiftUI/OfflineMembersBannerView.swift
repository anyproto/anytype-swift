import SwiftUI
import DesignKit

struct OfflineMembersBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.Text.primary)
            AnytypeText(Loc.Channel.Offline.membersBanner, style: .caption1Regular)
                .foregroundColor(.Text.primary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.horizontal, 16)
        .background(Color.Control.accent25)
        .clipShape(.rect(cornerRadius: 22))
    }
}
