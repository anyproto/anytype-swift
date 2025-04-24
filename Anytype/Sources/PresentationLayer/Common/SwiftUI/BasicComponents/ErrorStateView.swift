import SwiftUI

struct ErrorStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: .BottomAlert.error)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.error, style: .uxCalloutMedium)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            AnytypeText(message, style: .uxCalloutRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    ErrorStateView(message: "Error description")
}
