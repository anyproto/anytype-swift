import SwiftUI
import Services


struct MembershipOwnerInfoSheetView: View {    
    @State private var showManageSubscriptions = false
    
    @State private var email: String = ""
    @State private var showEmailVerification = false
    @State private var changeEmail = false
    @State private var toastData: ToastBarData = .empty
    
    // remove after middleware start to send update membership event
    @State private var justUpdatedEmail = false
    
    @StateObject private var model = MembershipOwnerInfoSheetViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(34)
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
        
        .sheet(isPresented: $showEmailVerification) {
            EmailVerificationView(email: $email) {
                showEmailVerification = false
                changeEmail = false
                justUpdatedEmail = true
                toastData = ToastBarData(text: Loc.emailSuccessfullyValidated, showSnackBar: true)
            }
        }
        .snackbar(toastBarData: $toastData)
    }
    
    var info: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.validUntil, style: .relation2Regular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(4)
            switch model.membership.tier?.type {
            case .explorer:
                AnytypeText(Loc.forever, style: .title)
                    .foregroundColor(.Text.primary)
                Spacer.fixedHeight(55)
            case .builder, .coCreator, .custom:
                AnytypeText(model.membership.formattedDateEnds, style: .title)
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
    
    private var actions: some View {
        Group {
            switch model.membership.tier?.type {
            case .explorer:
                explorerActions
            case .builder, .coCreator, .custom:
                managePaymentButton
            case nil:
                EmptyView()
            }
        }
    }
    
    private var alreadyHaveEmail: Bool {
        model.membership.email.isNotEmpty || justUpdatedEmail
    }
    
    private var explorerActions: some View {
        Group {
            if alreadyHaveEmail && !changeEmail {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(20)
                    StandardButton(Loc.changeEmail, style: .secondaryLarge) {
                        withAnimation {
                            UISelectionFeedbackGenerator().selectionChanged()
                            changeEmail = true
                        }
                    }
                }
            } else {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(40)
                    MembershipEmailActionView { email in
                        try await model.getVerificationEmail(email: email)
                        self.email = email
                        showEmailVerification = true
                    }
                }
            }
        }
    }
    
    private var managePaymentButton: some View {
        Group {
            if model.membership.paymentMethod == .methodInappApple {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(20)
                    StandardButton(Loc.managePayment, style: .secondaryLarge) {
                        AnytypeAnalytics.instance().logClickMembership(type: .managePayment)
                        showManageSubscriptions = true
                    }
                }
                .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
            }
        }
    }
}


#Preview("Explorer without email") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockExplorer, email: "")
        } content: {
            MembershipOwnerInfoSheetView()
        }
    }
}

#Preview("Explorer with email") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockExplorer, email: "vo@va.com")
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
