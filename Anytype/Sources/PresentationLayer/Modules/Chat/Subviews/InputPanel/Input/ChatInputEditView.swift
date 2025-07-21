import SwiftUI

struct ChatInputEditView: View {
    
    let onTapClose: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Text(Loc.Chat.editMessage)
                .anytypeStyle(.caption1Medium)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                onTapClose()
            } label: {
                Image(asset: .X24.close)
                    .foregroundStyle(Color.Control.primary)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color.Background.highlightedLight)
    }
}

