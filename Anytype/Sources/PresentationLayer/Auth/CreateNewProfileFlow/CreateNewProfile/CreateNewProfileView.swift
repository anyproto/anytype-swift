import SwiftUI

struct CreateNewProfileView: View {
    @State private var showImagePicker: Bool = false
    @State private var showSetupWallet: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: CreateNewProfileViewModel
    @StateObject var signUpData: SignUpData
    
    @State var showCreateNewProfile = true
    
    
    var body: some View {
        ZStack {
            Gradients.mainBackground()
            bottomSheet
                .horizontalReadabilityPadding(20)
                .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showImagePicker) {
            MediaPickerView(contentType: .images) { itemProvider in
                viewModel.setImage(signUpData: signUpData, itemProvider: itemProvider)
            }
        }
        .onAppear {
            AnytypeAnalytics.instance().logScreenAuthRegistration()
        }
    }
    
    private var bottomSheet: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                contentView
            }
            .background(Color.Background.primary)
            .cornerRadius(16.0)
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            imagePickerButton
            Spacer.fixedHeight(11)
            
            HStack {
                AnytypeText(Loc.newProfile, style: .caption1Regular, color: .Text.secondary)
                Spacer()
            }
            Spacer.fixedHeight(6)
            
            AutofocusedTextField(
                placeholder: Loc.enterYourName,
                placeholderFont: .uxBodyRegular,
                text: $signUpData.userName
            )
                .foregroundColor(.Text.primary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
                .disableAutocorrection(true)
                .divider(spacing: 10)
            
            Spacer.fixedHeight(20)
            
            buttons
            Spacer.fixedHeight(10)
        }
        .padding([.top, .horizontal], 20)
    }
    
    private var buttons: some View {
        HStack(spacing: 10) {
            StandardButton(Loc.back, style: .secondaryLarge) {
                self.presentationMode.wrappedValue.dismiss()
            }
            
            StandardButton(Loc.create, style: .primaryLarge) {
                showSetupWallet.toggle()
            }
            .addEmptyNavigationLink(
                destination: viewModel.showSetupWallet(signUpData: signUpData, showWaitingView: $showCreateNewProfile),
                isActive: $showSetupWallet
            )
            .disabled(signUpData.userName.isEmpty)
        }
    }
    
    private let imageWidth: CGFloat = 96
    private var imagePickerButton: some View {
        Button(action: {
            self.showImagePicker = true
        }) {
            ZStack {
                if let image = signUpData.image {
                    Image(uiImage: image.circleImage(width: imageWidth))
                    Color.black.opacity(0.05)
                        .clipShape(Circle())
                        .frame(width: imageWidth, height: imageWidth)
                } else {
                    Color.Stroke.primary
                        .clipShape(Circle())
                        .frame(width: imageWidth, height: imageWidth)
                }
                Image(asset: .authPhotoIcon)
            }
        }
    }
}


struct CreateNewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewProfileView(
            viewModel: CreateNewProfileViewModel(
                applicationStateService: DI.preview.serviceLocator.applicationStateService(),
                authService: DI.preview.serviceLocator.authService(),
                seedService: DI.preview.serviceLocator.seedService(),
                usecaseService: DI.preview.serviceLocator.usecaseService(),
                metricsService: DI.preview.serviceLocator.metricsService()
            ),
            signUpData: SignUpData(mnemonic: UUID().uuidString)
        )
        .environmentObject(SignUpData(mnemonic: ""))
    }
}
