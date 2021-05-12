import SwiftUI

struct SettingsSectionView: View {
    @ObservedObject var viewModel: ViewModel = .init()

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(name: "Wallpaper", icon: "Settings/wallpaper", pressed: self.$viewModel.wallpaper).modifier(DividerModifier())
            SettingsSectionItemView(name: "Keychain phrase", icon: "Settings/key", pressed: self.$viewModel.keychain).modifier(DividerModifier())
                .sheet(isPresented: self.$viewModel.keychain) {
                    KeychainPhraseView(viewModel: .init(), showKeychainView: self.$viewModel.keychain)
            }
            SettingsSectionItemView(name: "Pin code", icon: "Settings/lock", pressed: self.$viewModel.pincode).modifier(DividerModifier())
            SettingsSectionItemView(name: "About application", icon: "", pressed: self.$viewModel.about)
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

// MARK: - SettingsSectionView / ViewModel
extension SettingsSectionView {
    class ViewModel: ObservableObject {
        @Published var wallpaper: Bool = false
        @Published var keychain: Bool = false
        @Published var pincode: Bool = false
        @Published var about: Bool = false
    }
}

// MARK: - SettingsSectionView / DividerModifier
extension SettingsSectionView {
    struct DividerModifier: ViewModifier {
        func body(content: Content) -> some View {
            VStack {
                content
                Divider().foregroundColor(Color.divider)
            }
        }
    }
}


struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView()
            .previewLayout(.sizeThatFits)
    }
}
