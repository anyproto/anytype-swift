import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let style: Style
    let buttonData: ButtonData?
    
    init(title: String, subtitle: String, style: Style, buttonData: ButtonData? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.buttonData = buttonData
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            if style == .withImage {
                Image(asset: .BottomAlert.error)
                Spacer.fixedHeight(12)
            }
            AnytypeText(title, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            AnytypeText(subtitle, style: .uxBodyRegular, enableMarkdown: true)
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(12)
            if let buttonData {
                StandardButton(buttonData.title, style: .secondarySmall) {
                    buttonData.action()
                }
            }
            Spacer.fixedHeight(48)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

extension EmptyStateView {
    struct ButtonData {
        let title: String
        let action: () -> ()
    }
    
    enum Style {
        case withImage
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
