import SwiftUI
import AnytypeCore
import Assets
import AsyncTools

public struct BottomAlertView<Header: View, Body: View>: View {
    
    let title: String
    let message: String?
    let headerView: Header
    let bodyView: Body
    let buttons: [BottomAlertButton]
    
    public init(
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
    
    public var body: some View {
        VStack(spacing: 19) {
            VStack(spacing: 15) {
                headerView
                VStack(spacing: 8) {
                    titleView
                    messageView
                    bodyView
                }
            }
            buttonsView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.Background.secondary)
    }
    
    @ViewBuilder
    private var titleView: some View {
        AnytypeText(title, style: .heading)
            .foregroundColor(.Text.primary)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var messageView: some View {
        if let message, message.isNotEmpty {
            AnytypeText(message, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var buttonsView: some View {
        BottomAlertButtonView(buttons: buttons)
    }
}

public extension BottomAlertView where Header == EmptyView, Body == EmptyView {
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

public extension BottomAlertView where Header == Image, Body == EmptyView {
    
    init(
        title: String,
        message: String? = nil,
        icon: ImageAsset,
        @ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]
    ) {
        self = BottomAlertView(
            title: title,
            message: message,
            headerView: {
                Image(asset: icon)
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
            BottomAlertButton(text: "Button", style: .secondary, action: {
                try await Task.sleep(seconds: 10)
            })
            BottomAlertButton(text: "Button", style: .primary, action: {
                try await Task.sleep(seconds: 10)
            })
        }
        .border(Color.gray)
}

#Preview("With header") {
    BottomAlertView(
        title: "Title",
        message: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog",
        icon: .BottomAlert.update) {
            BottomAlertButton(text: "Button", style: .secondary, action: {})
            BottomAlertButton(text: "Button", style: .primary, action: {})
        }
        .border(Color.gray)
}

#Preview("Long button text") {
    BottomAlertView(
        title: "Title",
        message: "Mes",
        icon: .BottomAlert.update) {
            BottomAlertButton(text: "Button 1111111111 11111", style: .secondary, action: {})
            BottomAlertButton(text: "Button", style: .primary, action: {})
        }
        .border(Color.gray)
}
