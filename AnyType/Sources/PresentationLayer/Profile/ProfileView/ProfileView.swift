import SwiftUI

struct ProfileView: View {
    @StateObject var model: ProfileViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.loginBackground, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                contentView.padding(.bottom, 10)
            }
        }
        .errorToast(isShowing: $model.isShowingError, errorText: model.error)
        
        .environmentObject(model)
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingsSectionView()
            StandardButton(disabled: false, text: "Log out", style: .secondary) {
                self.model.logout()
            }
            .padding(.horizontal, 20)
        }
        .padding([.leading, .trailing], 20)
    }
}
