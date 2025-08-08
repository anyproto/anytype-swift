import SwiftUI

struct MultilineLimitTextEditor: View {
    
    let placeholder: String
    let font: AnytypeFont
    let axis: Axis
    let limit: Int
    let warningLimit: Int
    @Binding var text: String
    
    var body: some View {
        AnytypeTextField(placeholder: placeholder, font: font, axis: axis, text: $text)
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
private struct MultilineLimitTextEditor_Preview: View {
    
    @State var text = "2"
    
    var body: some View {
        MultilineLimitTextEditor(
            placeholder: "Add a comment...",
            font: .bodyRegular,
            axis: .vertical,
            limit: 20,
            warningLimit: 15,
            text: $text
        )
    }
}

#Preview {
    ZStack {
        MultilineLimitTextEditor_Preview()
            .padding()
    }
    .background(Color.red)
}
