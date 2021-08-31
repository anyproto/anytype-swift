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
            bottomSheet
                .padding(20)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $signUpData.image)
        }
    }
    
    private var bottomSheet: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                contentView
            }
            .background(Color.background)
            .cornerRadius(16.0)
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            imagePickerButton
                .padding(.bottom, 11)
            
            HStack {
                AnytypeText("New profile", style: .caption1Regular)
                    .foregroundColor(.textSecondary)
                Spacer()
            }.padding(.bottom, 6)
            
            TextField("Enter your name", text: $signUpData.userName)
                .font(AnytypeFontBuilder.font(textStyle: .heading))
                .modifier(DividerModifier(spacing: 10))
                .padding(.bottom, 20)
            
            buttons
        }
        .padding([.top, .horizontal], 20)
        .padding(.bottom, 10)
    }
    
    private var buttons: some View {
        HStack(spacing: 10) {
            StandardButton(disabled: false, text: "Back", style: .secondary) {
                self.presentationMode.wrappedValue.dismiss()
            }
            
            NavigationLink(
                destination: viewModel.showSetupWallet(signUpData: signUpData, showWaitingView: $showCreateNewProfile)
            ) {
                StandardButtonView(disabled: signUpData.userName.isEmpty, text: "Create", style: .primary)
            }.disabled(signUpData.userName.isEmpty)
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
                    Color.stroke
                        .clipShape(Circle())
                        .frame(width: imageWidth, height: imageWidth)
                }
                Image.auth.photo
            }
        }
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
