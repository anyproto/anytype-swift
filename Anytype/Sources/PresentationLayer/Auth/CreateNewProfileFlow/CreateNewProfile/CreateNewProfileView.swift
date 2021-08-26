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
    }
    
    private var contentView: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                imagePickerButton.padding(.bottom, 11)
                HStack {
                    AnytypeText("New profile", style: .caption1Regular)
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
                .padding(.bottom, 6)
                CustomTextField(text: $signUpData.userName, title: "Enter your name")
                    .font(AnytypeFontBuilder.font(textStyle: .heading))
                    .padding(.bottom, 20)
                
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
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 10)
            .background(Color.background)
            .cornerRadius(16.0)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $signUpData.image)
        }
    }
    
    private var imagePickerButton: some View {
        Button(action: {
            self.showImagePicker = true
        }) {
            if !signUpData.image.isNil {
                ImageWithCircleBackgroundView(
                    image: Image.auth.photo,
                    backgroundImage: signUpData.image
                )
            } else {
                ImageWithCircleBackgroundView(
                    image: Image.auth.photo,
                    backgroundColor: .stroke
                )
            }
        }
        .frame(width: 96, height: 96)
    }
}


struct CreateNewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewProfileView(
            viewModel: CreateNewProfileViewModel(),
            showCreateNewProfile: .constant(true)
        )
        .environmentObject(SignUpData())
    }
}
