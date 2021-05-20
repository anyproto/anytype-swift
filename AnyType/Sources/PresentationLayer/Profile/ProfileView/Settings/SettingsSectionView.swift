import SwiftUI

struct SettingsSectionView: View {
    @ObservedObject var viewModel = SettingSectionViewModel()

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(name: "Wallpaper", icon: Image.settings.wallpaper, pressed: self.$viewModel.wallpaper)
                .modifier(DividerModifier())
            SettingsSectionItemView(name: "Keychain phrase", icon: Image.settings.keychain, pressed: self.$viewModel.keychain)
                .modifier(DividerModifier())
                .sheet(isPresented: self.$viewModel.keychain) {
                    KeychainPhraseView(viewModel: .init())
                }
            SettingsSectionItemView(name: "Pin code", icon: Image.settings.pin, pressed: self.$viewModel.pincode)
                .modifier(DividerModifier())
            SettingsSectionItemView(name: "About application", icon: Image.settings.about, pressed: self.$viewModel.about)
                .sheet(isPresented: self.$viewModel.about) {
                    ProfileView.AboutView(viewModel: .init())
                }
        }
        .padding([.leading, .trailing], 20)
        .padding([.bottom, .top], 20)
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
