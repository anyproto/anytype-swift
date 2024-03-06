import SwiftUI
import AnytypeCore

struct BottomAlertView<Header: View, Body: View>: View {
    
    let title: String
    let message: String?
    let headerView: Header
    let bodyView: Body
    let buttons: [BottomAlertButton]
    
    init(
        title: String,
        message: String? = nil,
        @ViewBuilder headerView: () -> Header,
        @ViewBuilder bodyView: () -> Body,
        @ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]
    ) {
        self.title = title
        self.message = message
        self.headerView = headerView()
        self.bodyView = bodyView()
        self.buttons = buttons()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            headerView
            titleView
            messageView
            bodyView
            buttonsView
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
    }
    
    @ViewBuilder
    private var titleView: some View {
        AnytypeText(title, style: .heading, color: .Text.primary)
            .multilineTextAlignment(.center)
            .padding(.top, 15)
            .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private var messageView: some View {
        if let message, message.isNotEmpty {
            AnytypeText(message, style: .bodyRegular, color: .Text.primary)
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
        }
    }
    
    private var buttonsView: some View {
        BottomAlertButtonView(buttons: buttons)
            .padding(.top, 10)
            .padding(.bottom, 16)
    }
}

extension BottomAlertView where Header == EmptyView, Body == EmptyView {
    init(
        title: String,
        message: String? = nil,
        @ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]
    ) {
        self = BottomAlertView(
            title: title,
            message: message,
            headerView: { EmptyView() },
            bodyView: { EmptyView() },
            buttons: buttons
        )
    }
}

extension BottomAlertView where Header == ButtomAlertHeaderImageView, Body == EmptyView {
    init(
        title: String,
        message: String? = nil,
        icon: ImageAsset,
        color: BottomAlertHeaderBackgroundColor,
        @ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]
    ) {
        self.init(title: title, icon: icon, style: .color(color), buttons: buttons)
    }
    
    
    init(
        title: String,
        message: String? = nil,
        icon: ImageAsset,
        style: BottomAlertHeaderBackgroundStyle,
        @ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]
    ) {
        self = BottomAlertView(
            title: title,
            message: message,
            headerView: {
                ButtomAlertHeaderImageView(icon: icon, style: style)
            },
            bodyView: { EmptyView() },
            buttons: buttons
        )
    }
}

#Preview("Withuot header") {
    BottomAlertView(
        title: "Title",
        message: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog") {
            BottomAlertButton(text: "Button", style: .secondary, action: {})
            BottomAlertButton(text: "Button", style: .primary, action: {})
        }
}

#Preview("With header") {
    BottomAlertView(
        title: "Title",
        message: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog",
        icon: .BottomAlert.update,
        color: .green) {
            BottomAlertButton(text: "Button", style: .secondary, action: {})
            BottomAlertButton(text: "Button", style: .primary, action: {})
        }
}

#Preview("Long button text") {
    BottomAlertView(
        title: "Title",
        message: "Mes",
        icon: .BottomAlert.update,
        color: .green) {
            BottomAlertButton(text: "Button 1111111111 11111", style: .secondary, action: {})
            BottomAlertButton(text: "Button", style: .primary, action: {})
        }
}
