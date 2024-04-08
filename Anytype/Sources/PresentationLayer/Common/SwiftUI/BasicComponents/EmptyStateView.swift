import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let buttonData: ButtonData?
    
    init(title: String, subtitle: String, buttonData: ButtonData? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.buttonData = buttonData
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .color(.red))
            Spacer.fixedHeight(12)
            AnytypeText(title, style: .uxCalloutMedium)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            AnytypeText(subtitle, style: .uxCalloutRegular)
                .foregroundColor(.Text.primary)
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
}

#Preview {
    EmptyStateView(
        title: Loc.Relation.EmptyState.title,
        subtitle: Loc.Relation.EmptyState.description,
        buttonData: EmptyStateView.ButtonData(
            title: Loc.create,
            action: {}
        )
    )
}
