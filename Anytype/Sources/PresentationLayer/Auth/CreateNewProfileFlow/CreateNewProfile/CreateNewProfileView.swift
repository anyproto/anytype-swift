import SwiftUI
import Amplitude

struct CreateNewProfileView: View {
    @State private var showImagePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: CreateNewProfileViewModel
    @EnvironmentObject var signUpData: SignUpData
    
    @Binding var showCreateNewProfile: Bool
    
    
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
            ImagePicker(image: $signUpData.image)
        }
        .onAppear {
            Amplitude.instance().logEvent(AmplitudeEventsName.authScreenShow)
        }
    }
    
    private var bottomSheet: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                contentView
            }
            .background(Color.backgroundPrimary)
            .cornerRadius(16.0)
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            imagePickerButton
            Spacer.fixedHeight(11)
            
            HStack {
                AnytypeText("New profile".localized, style: .caption1Regular, color: .textSecondary)
                Spacer()
            }
            Spacer.fixedHeight(6)
            
            AutofocusedTextField(title: "", text: $signUpData.userName)
                .foregroundColor(.textPrimary)
                .font(AnytypeFontBuilder.font(anytypeFont: .heading))
                .placeholder(when: signUpData.userName.isEmpty) {
                    AnytypeText("Enter your name".localized, style: .heading, color: .textTertiary)
                }
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
            StandardButton(disabled: false, text: "Back".localized, style: .secondary) {
                self.presentationMode.wrappedValue.dismiss()
            }
            
            NavigationLink(
                destination: viewModel.showSetupWallet(signUpData: signUpData, showWaitingView: $showCreateNewProfile)
            ) {
                StandardButtonView(disabled: signUpData.userName.isEmpty, text: "Create".localized, style: .primary)
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
                    Color.strokePrimary
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
