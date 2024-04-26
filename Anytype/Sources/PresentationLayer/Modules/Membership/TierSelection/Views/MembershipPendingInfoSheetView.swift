import SwiftUI
import Services


struct MembershipPendingInfoSheetView: View {
    let membership: MembershipStatus
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(34)
            AnytypeText(Loc.yourCurrentStatus, style: .bodySemibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(14)
            info
            Spacer.fixedHeight(46)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .cornerRadius(16, corners: .top)
    }
    
    var info: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.pending, style: .title)
                .foregroundColor(.Text.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(Color.Shape.tertiary)
        .cornerRadius(12, style: .continuous)
    }
}

#Preview {
    MembershipPendingInfoSheetView(membership: .empty)
}
