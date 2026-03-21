import SwiftUI

struct EmptyStateView<ButtonContent: View>: View {
    let title: String
    let subtitle: String
    let style: Style
    let buttonData: ButtonData?
    let customButton: ButtonContent?
    
    init(title: String, subtitle: String = "", style: Style, buttonData: ButtonData? = nil) where ButtonContent == Never {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.buttonData = buttonData
        self.customButton = nil
    }

    init(title: String, subtitle: String = "", style: Style, @ViewBuilder button: () -> ButtonContent) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.buttonData = nil
        self.customButton = button()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            switch style {
            case .withImage:
                Image(asset: .Dialog.coffee)
                    .foregroundStyle(Color.Control.primary)
                Spacer.fixedHeight(12)
            case .error:
                Image(asset: .Dialog.duck)
                Spacer.fixedHeight(12)
            case .plain:
                EmptyView()
            }
            
            AnytypeText(title, style: .uxBodyRegular)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)
            if subtitle.isNotEmpty {
                AnytypeText(subtitle, style: .uxBodyRegular, enableMarkdown: true)
                    .foregroundStyle(Color.Text.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer.fixedHeight(12)
            if let buttonData {
                AsyncStandardButton(buttonData.title, style: .secondarySmall) {
                    try await buttonData.action()
                }
            } else if let customButton {
                customButton
            }
            Spacer.fixedHeight(48)
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
}

extension EmptyStateView {
    struct ButtonData {
        let title: String
        let action: () async throws -> ()
    }
    
    enum Style {
        case withImage
        case error
        case plain
    }
}

#Preview {
    EmptyStateView(
        title: Loc.Relation.EmptyState.title,
        subtitle: Loc.Relation.EmptyState.description,
        style: .withImage,
        buttonData: EmptyStateView.ButtonData(
            title: Loc.create,
            action: {}
        )
    )
}
