import SwiftUI

struct ErrorStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .color(.red))
            Spacer.fixedHeight(12)
            AnytypeText(Loc.error, style: .uxCalloutMedium, color: .Text.primary)
                .multilineTextAlignment(.center)
            AnytypeText(message, style: .uxCalloutRegular, color: .Text.primary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ErrorStateView(message: "Error description")
}
