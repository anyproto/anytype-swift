import SwiftUI

struct ChatMessageHeaderView: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .anytypeFontStyle(.caption1Medium)
                .foregroundColor(.Text.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.Background.navigationPanel)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .frame(height: 50)
                .lineLimit(1)
            Spacer()
        }
    }
}
