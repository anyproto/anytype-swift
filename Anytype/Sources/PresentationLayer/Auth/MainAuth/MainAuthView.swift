import SwiftUI
import Amplitude


struct MainAuthView: View {
    @ObservedObject var viewModel: MainAuthViewModel
    @State private var userAnalyticsConsent: Bool = UserDefaultsConfig.analyticsUserConsent

    var body: some View {
        ZStack {
            navigation
            Gradients.mainBackground()
            contentView
                
            .errorToast(
                isShowing: $viewModel.isShowingError, errorText: viewModel.error
            )
        }
        .navigationBarHidden(true)
        .modifier(LogoOverlay())
        .onAppear {
            viewModel.viewLoaded()
        }
        .onChange(of: userAnalyticsConsent) { newValue in
            UserDefaultsConfig.analyticsUserConsent = newValue
        }
    }
    
    private var contentView: some View {
        VStack() {
            Spacer()
            bottomSheet
                .horizontalReadabilityPadding(20)
        }
    }
    
    private var bottomSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if userAnalyticsConsent {
                    standartContent
                } else {
                    analyticsConsentView
                }
            }
            .transition(.identity)
            .padding(EdgeInsets(top: 23, leading: 20, bottom: 10, trailing: 20))
        }
        .background(Color.backgroundPrimary)
        .cornerRadius(16.0)
    }
    
    private var analyticsConsentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText("On analytics".localized, style: .heading, color: .textPrimary)
            Spacer.fixedHeight(11)
            AnytypeText("Analytics constent text".localized, style: .uxCalloutRegular, color: .textPrimary)
                .padding(.trailing, 5)
            Spacer.fixedHeight(18)
            StandardButton(text: "Start".localized, style: .primary) {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.fastSpring) {
                    userAnalyticsConsent = true
                }
            }
        }
        .onAppear {
            Amplitude.instance().logEvent(AmplitudeEventsName.disclaimerShow)
        }
    }
    
    private var standartContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText("Welcome to Anytype".localized, style: .heading, color: .textPrimary)
            Spacer.fixedHeight(11)
            AnytypeText("OrganizeEverythingDescription".localized, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(18)
            buttons
        }
    }
    
    private var buttons: some View {
        HStack(spacing: 10) {
            StandardButton(text: "Sign up".localized, style: .secondary) {
                viewModel.singUp()
            }
            
            NavigationLink(
                destination: viewModel.loginView()
            ) {
                StandardButtonView(text: "Login".localized, style: .primary)
            }
        }
    }
    
    private var navigation: some View {
        NavigationLink(
            destination: viewModel.signUpFlow(),
            isActive: $viewModel.showSignUpFlow
        ) {
            EmptyView()
        }
        .navigationBarHidden(true)
    }
}


struct MainAuthView_Previews : PreviewProvider {
    static var previews: some View {
        MainAuthView(viewModel: MainAuthViewModel())
    }
}
