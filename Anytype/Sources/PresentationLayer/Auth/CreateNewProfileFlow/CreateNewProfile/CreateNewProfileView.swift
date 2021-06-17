import SwiftUI


struct CreateNewProfileView: View {
    @State private var showImagePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: CreateNewProfileViewModel
    @EnvironmentObject var signUpData: SignUpData
    
    @Binding var showCreateNewProfile: Bool
    
    
    var body: some View {
        ZStack {
            Gradients.authBackground()
            contentView
                .padding()
        }
        .navigationBarHidden(true)
        .modifier(LogoOverlay())
    }
    
    private var contentView: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText("Create a new profile", style: .title)
                    .padding(.bottom, 27)
                HStack {
                    Button(action: {
                        self.showImagePicker = true
                    }) {
                        if !signUpData.image.isNil {
                            ImageWithCircleBackgroundView(image: Image.auth.photo, backgroundImage: signUpData.image)
                        } else {
                            ImageWithCircleBackgroundView(image: Image.auth.photo, backgroundColor: .gray)
                        }
                    }
                    .frame(width: 64, height: 64)
                    
                    CustomTextField(text: $signUpData.userName, title: "Enter your name")
                }
                .padding(.bottom, 24)
                
                HStack(spacing: 12) {
                    StandardButton(disabled: false, text: "Back", style: .secondary) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    NavigationLink(
                        destination: viewModel.showSetupWallet(signUpData: signUpData, showWaitingView: $showCreateNewProfile)
                    ) {
                        StandardButtonView(disabled: signUpData.userName.isEmpty, text: "Create", style: .primary)
                    }.disabled(signUpData.userName.isEmpty)
                }
                .padding(.bottom, 16)
            }
            .navigationBarBackButtonHidden(true)
            .padding()
            .background(Color.background)
            .cornerRadius(12.0)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $signUpData.image)
        }
    }
}


struct CreateNewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewProfileView(viewModel: CreateNewProfileViewModel(), showCreateNewProfile: .constant(true))
    }
}
