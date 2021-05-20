import SwiftUI

struct SettingsSectionView: View {
    @ObservedObject var viewModel = SettingSectionViewModel()

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(
                name: "Wallpaper",
                icon: Image.settings.wallpaper,
                comingSoon: true,
                pressed: $viewModel.wallpaper
            )
            .modifier(DividerModifier())
            
            SettingsSectionItemView(
                name: "Keychain phrase",
                icon: Image.settings.keychain,
                comingSoon: false,
                pressed: $viewModel.keychain
            )
            .modifier(DividerModifier())
            .sheet(isPresented: $viewModel.keychain) {
                KeychainPhraseView(viewModel: .init())
            }
            
            SettingsSectionItemView(
                name: "Pin code",
                icon: Image.settings.pin,
                comingSoon: true,
                pressed: $viewModel.pincode
            )
            .modifier(DividerModifier())
            
            SettingsSectionItemView(
                name: "About",
                icon: Image.settings.about,
                comingSoon: false,
                pressed: $viewModel.about
            )
            .modifier(DividerModifier())
            .sheet(isPresented: $viewModel.about) {
                ProfileView.AboutView(viewModel: .init())
            }
        }
        .padding([.leading, .trailing], 20)
        .background(Color.background)
        .cornerRadius(12.0)
    }
}


struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView()
            .previewLayout(.sizeThatFits)
    }
}
