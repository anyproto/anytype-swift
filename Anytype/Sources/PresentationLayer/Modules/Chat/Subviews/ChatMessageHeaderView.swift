import SwiftUI

struct ChatMessageHeaderView: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .anytypeFontStyle(.caption1Medium)
                .foregroundColor(.Text.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.Control.transparentActive)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .frame(height: 50)
                .lineLimit(1)
            Spacer()
        }
    }
}
