import SwiftUI
import AnytypeCore

struct BottomAlertView: View {
    
    let title: String
    let message: String
    let icon: ImageAsset?
    let style: BottomAlertHeaderBackgroundStyle?
    let buttons: [BottomAlertButton]
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(4)
            if let icon, let style {
                ButtomAlertHeaderImageView(icon: icon, style: style)
                Spacer.fixedHeight(15)
            } else {
                Spacer.fixedHeight(10)
            }
            AnytypeText(title, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(7)
            AnytypeText(message, style: .bodyRegular, color: .Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(30)
            BottomAlertButtonView(buttons: buttons)
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
    }
}

extension BottomAlertView {
    init(
        title: String,
        message: String,
        @ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]
    ) {
        self.title = title
        self.message = message
        self.icon = nil
        self.style = nil
        self.buttons = buttons()
    }
    
    init(
        title: String,
        message: String,
        icon: ImageAsset,
        style: BottomAlertHeaderBackgroundStyle,
        @ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.style = style
        self.buttons = buttons()
    }
}

#Preview("Withuot header") {
    BottomAlertView(
        title: "Title",
        message: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog") {
            BottomAlertButton(text: "Button", style: .secondary, action: {})
            BottomAlertButton(text: "Button", style: .primary, loading: true, action: {})
        }
}

#Preview("With header") {
    BottomAlertView(
        title: "Title",
        message: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog",
        icon: .BottomAlert.update,
        style: .green) {
            BottomAlertButton(text: "Button", style: .secondary, action: {})
            BottomAlertButton(text: "Button", style: .primary, loading: true, action: {})
        }
}
