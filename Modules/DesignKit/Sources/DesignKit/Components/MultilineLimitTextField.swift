import SwiftUI

public struct MultilineLimitTextField: View {
    
    let placeholder: String
    let limit: Int
    let warningLimit: Int
    @Binding var text: String
    
    public init(
        placeholder: String,
        limit: Int,
        warningLimit: Int,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self.limit = limit
        self.warningLimit = warningLimit
        self._text = text
    }
    
    public var body: some View {
        AnytypeTextField(placeholder: placeholder, font: .bodyRegular, axis: .vertical, text: $text)
            .padding(.horizontal, 16)
            .frame(minHeight: 48, maxHeight: 64, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.Background.secondary)
            .cornerRadius(12)
            .border(12, color: .Shape.primary, lineWidth: 0.5)
            .overlay(alignment: .top) {
                if limit - text.count < 0 {
                    TextLimitView(
                        text: "\(text.count) / \(limit)",
                        limitReached: true
                    )
                } else if warningLimit - text.count < 0 {
                    TextLimitView(
                        text: "\(text.count) / \(limit)",
                        limitReached: false
                    )
                }
                
            }
    }
}

// Use @Previewable @State from iOS 17
private struct MultilineLimitTextField_Preview: View {
    
    @State var text = "2"
    
    var body: some View {
        MultilineLimitTextField(
            placeholder: "Add a comment...",
            limit: 20,
            warningLimit: 15,
            text: $text
        )
    }
}

#Preview {
    ZStack {
        MultilineLimitTextField_Preview()
            .padding()
    }
    .background(Color.red)
}
