import SwiftUI
import Services


struct MembershipOwnerInfoSheetView: View {
    let membership: MembershipStatus
    
    @State private var showManageSubscriptions = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(34)
            AnytypeText(Loc.yourCurrentStatus, style: .bodySemibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(14)
            info
            managePaymentButton
            Spacer.fixedHeight(46)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .cornerRadius(16, corners: .top)
    }
    
    var info: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.validUntil, style: .relation2Regular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(4)
            switch membership.tier?.type {
            case .explorer:
                AnytypeText(Loc.forever, style: .title)
                    .foregroundColor(.Text.primary)
                Spacer.fixedHeight(55)
            case .builder, .coCreator, .custom:
                AnytypeText(membership.formattedDateEnds, style: .title)
                    .foregroundColor(.Text.primary)
                paymentText
            case .none:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 34)
        .background(Color.Shape.tertiary)
        .cornerRadius(12, style: .continuous)
    }
    
    var paymentText: some View {
        Group {
            if let paymentMethod = membership.localizablePaymentMethod {
                Spacer.fixedHeight(23)
                AnytypeText(Loc.paidBy(paymentMethod), style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
                Spacer.fixedHeight(15)
            } else {
                Spacer.fixedHeight(55)
            }
        }
    }
    
    private var managePaymentButton: some View {
        Group {
            if membership.paymentMethod == .methodInappApple {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(20)
                    StandardButton(Loc.managePayment, style: .secondaryLarge) {
                        showManageSubscriptions = true
                    }
                }
                .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
            }
        }
    }
}

#Preview {
    NavigationView {
        ScrollView(.horizontal) {
            HStack {
                MembershipOwnerInfoSheetView(
                    membership: MembershipStatus(
                        tier: .mockExplorer,
                        status: .active,
                        dateEnds: .tomorrow,
                        paymentMethod: .methodStripe,
                        anyName: ""
                    )
                )
                MembershipOwnerInfoSheetView(
                    membership: MembershipStatus(
                        tier: .mockBuilder,
                        status: .pending,
                        dateEnds: .tomorrow,
                        paymentMethod: .methodCrypto,
                        anyName: ""
                    )
                )
                MembershipOwnerInfoSheetView(
                    membership: MembershipStatus(
                        tier: .mockCoCreator,
                        status: .active,
                        dateEnds: .tomorrow,
                        paymentMethod: .methodInappApple,
                        anyName: ""
                    )
                )
            }
        }
    }
}
