import SwiftUI
import Services


struct MembershipOwnerInfoSheetView: View {
    let tier: MembershipTier
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(34)
            AnytypeText(Loc.yourCurrentStatus, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(14)
            info
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .cornerRadius(16, corners: .top)
    }
    
    var info: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.validUntil, style: .relation2Regular, color: .Text.primary)
            Spacer.fixedHeight(4)
            switch tier {
            case .explorer:
                AnytypeText(Loc.forever, style: .title, color: .Text.primary)
                Spacer.fixedHeight(55)
            case .builder, .coCreator:
                AnytypeText("%Date%", style: .title, color: .Text.primary)
                Spacer.fixedHeight(23)
                AnytypeText(Loc.paidBy("%Card%"), style: .relation3Regular, color: .Text.secondary)
                Spacer.fixedHeight(15)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 34)
        .background(Color.Shape.tertiary)
        .cornerRadius(12, style: .continuous)
    }
}

#Preview {
    MembershipOwnerInfoSheetView(tier: .builder)
}
