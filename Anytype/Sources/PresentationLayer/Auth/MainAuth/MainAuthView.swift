import SwiftUI


struct MainAuthView: View {
    @ObservedObject var viewModel: MainAuthViewModel
    @State private var userAnalyticsConsent: Bool = UserDefaultsConfig.analyticsUserConsent
    @State private var showLogInView: Bool = false
    
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
                .padding(.bottom, 20)
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
        .background(Color.Background.primary)
        .cornerRadius(16.0)
    }
    
    private var analyticsConsentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(Loc.onAnalytics, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(11)
            AnytypeText(Loc.analyticsConstentText, style: .uxCalloutRegular, color: .Text.primary)
                .padding(.trailing, 5)
            Spacer.fixedHeight(18)
            StandardButton(Loc.start, style: .primaryLarge) {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.fastSpring) {
                    userAnalyticsConsent = true
                }
            }
        }
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.disclaimerShow)
        }
    }
    
    private var standartContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(Loc.welcomeToAnytype, style: .heading, color: .Text.primary)
            Spacer.fixedHeight(11)
            AnytypeText(Loc.organizeEverythingDescription, style: .uxCalloutRegular, color: .Text.primary)
            Spacer.fixedHeight(18)
            buttons
        }
    }
    
    private var buttons: some View {
        HStack(spacing: 10) {
            StandardButton(Loc.signUp, style: .secondaryLarge) {
                viewModel.singUp()
            }
            
            StandardButton(Loc.login, style: .primaryLarge) {
                showLogInView.toggle()
            }
            .addEmptyNavigationLink(destination: viewModel.loginView(), isActive: $showLogInView)
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
        MainAuthView(viewModel: MainAuthViewModel(applicationStateService: DI.preview.serviceLocator.applicationStateService()))
    }
}
