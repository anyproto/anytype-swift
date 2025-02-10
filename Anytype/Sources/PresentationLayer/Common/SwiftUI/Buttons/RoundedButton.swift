import SwiftUI

struct RoundedButton: View {
    
    let text: String
    let icon: ImageAsset?
    let action: () -> Void
    
    init(text: String, icon: ImageAsset? = nil, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                if let icon {
                    IconView(asset: icon).frame(width: 24, height: 24)
                    Spacer.fixedWidth(8)
                }
                AnytypeText(text, style: .previewTitle1Regular)
                Spacer()
                IconView(asset: .X24.Arrow.right).frame(width: 24, height: 24)
            }
            .padding(20)
            .border(12, color: .Shape.primary, lineWidth: 0.5)
        }
    }
}

#Preview {
    RoundedButton(text: "ClickMe", icon: .X24.attachment) { }
}
