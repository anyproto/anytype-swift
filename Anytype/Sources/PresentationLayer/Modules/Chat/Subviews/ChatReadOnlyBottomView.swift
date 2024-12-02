import SwiftUI

struct ChatReadOnlyBottomView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            IconView(asset: .X18.lock)
                .foregroundStyle(Color.Control.button)
            Text(Loc.Chat.readOnly)
                .anytypeStyle(.caption1Regular)
                .foregroundStyle(Color.Text.primary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Background.navigationPanel)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}
