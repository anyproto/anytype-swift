import SwiftUI
import Services


struct MembershipOwnerInfoSheetView: View {    
    @StateObject private var model = MembershipOwnerInfoSheetViewModel()
    
    var body: some View {
        content
            .onAppear {
                model.updateState()
            }
            .onChange(of: model.membership) { _ in
                model.updateState()
            }
        
            .snackbar(toastBarData: $model.toastData)
            .sheet(isPresented: $model.showEmailVerification) {
                EmailVerificationView(email: $model.email) {
                    model.onSuccessfullEmailVerification()
                }
            }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            AnytypeText(Loc.yourCurrentStatus, style: .bodySemibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(14)
            info
            actions
            Spacer.fixedHeight(46)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .cornerRadius(16, corners: .top)
    }
    
    private var info: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.validUntil, style: .relation2Regular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(4)
            switch model.membership.tier?.type {
            case .starter, .builder, .coCreator, .custom:
                AnytypeText(model.membership.formattedDateEnds, style: .title)
                    .foregroundColor(.Text.primary)
                paymentText
            case .anyTeam:
                AnytypeText(model.membership.formattedDateEnds, style: .title)
                    .foregroundColor(.Text.primary)
                Spacer.fixedHeight(23)
                AnytypeText(Loc.paidBy("your faith and love"), style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
                Spacer.fixedHeight(15)
            case .none:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 34)
        .background(Color.Shape.tertiary)
        .cornerRadius(12, style: .continuous)
    }
    
    private var paymentText: some View {
        Group {
            if let paymentMethod = model.membership.localizablePaymentMethod {
                Spacer.fixedHeight(23)
                AnytypeText(Loc.paidBy(paymentMethod), style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
                Spacer.fixedHeight(15)
            } else {
                Spacer.fixedHeight(55)
            }
        }
    }
    
    private var mailActions: some View {
        Group {
            if model.alreadyHaveEmail && !model.changeEmail {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(20)
                    StandardButton(Loc.changeEmail, style: .secondaryLarge) {
                        withAnimation {
                            UISelectionFeedbackGenerator().selectionChanged()
                            model.changeEmail = true
                        }
                    }
                }
            } else {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(12)
                    MembershipEmailActionView { email in
                        try await model.getVerificationEmail(email: email)
                    }
                }
            }
        }
    }
    
    private var actions: some View {
        Group {
            switch model.purchaseType {
            case .purchasedInAppStoreWithCurrentAccount:
                managePaymentButton
            case .purchasedElsewhere(let externalPaymentMethod):
                managePaymentNotice(paymentMethod: externalPaymentMethod)
            case .freeTier:
                mailActions
            case .none:
                EmptyView()
            }
        }
    }
    
    private var managePaymentButton: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(20)
            StandardButton(Loc.managePayment, style: .secondaryLarge) {
                AnytypeAnalytics.instance().logClickMembership(type: .managePayment)
                model.showManageSubscriptions = true
            }
        }
        .manageSubscriptionsSheet(isPresented: $model.showManageSubscriptions)
    }
    
    private func managePaymentNotice(paymentMethod: MembershipExternalPaymentMethod) -> some View {
        Group {
            AnytypeText(paymentMethod.noticeText, style: .relation2Regular)
                .foregroundColor(.Text.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center) 
                .padding(.vertical)
        }
    }
}


#Preview("Starter without email") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockStarter, email: "")
        } content: {
            MembershipOwnerInfoSheetView()
        }
    }
}

#Preview("Starter with email") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockStarter, email: "vo@va.com")
        } content: {
            MembershipOwnerInfoSheetView()
        }
    }
}


#Preview("Stripe builder") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockBuilder, paymentMethod: .methodStripe)
        } content: {
            MembershipOwnerInfoSheetView()
        }
    }
}

#Preview("InApp CockReator") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockCoCreator, paymentMethod: .methodInappApple)
        } content: {
            MembershipOwnerInfoSheetView()
        }
    }
}
