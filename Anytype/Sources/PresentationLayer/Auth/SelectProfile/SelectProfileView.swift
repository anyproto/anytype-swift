import SwiftUI


struct SelectProfileView: View {
    @StateObject var viewModel: SelectProfileViewModel
    @State private var showCreateProfileView = false
    @State private var contentHeight: CGFloat = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            ZStack(alignment: self.viewModel.isMultipleAccountsEnabled ? .bottom : .center) {
                Gradients.authBackground()
                
                if self.viewModel.isMultipleAccountsEnabled {
                    multipleAccountsPicket
                } else {
                    ProgressView()
                }
            }
        }
        .errorToast(isShowing: $viewModel.showError, errorText: viewModel.error ?? "") {
            presentationMode.wrappedValue.dismiss()
        }
        .navigationBarHidden(true)
        .modifier(LogoOverlay())
        .onAppear {
            viewModel.accountRecover()
        }
    }
    
    private func contentHeight(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.contentHeight = proxy.size.height
        }
        return Color.clear
    }
    
    private var multipleAccountsPicket: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    AnytypeText("Choose profile", style: .title)
                        .animation(nil)
                    
                    ForEach(self.viewModel.profilesViewModels) { profile in
                        Button(action: {
                            self.viewModel.selectProfile(id: profile.id)
                        }) {
                            ProfileNameView(viewModel: profile)
                        }
                        .transition(.opacity)
                    }
                    .animation(nil)
//                    NavigationLink(destination: self.viewModel.showCreateProfileView()) {
//                        AddProfileView()
//                    }
                    .animation(nil)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    GeometryReader { proxy in
                        self.contentHeight(proxy: proxy)
                })
                    .animation(.easeInOut(duration: 0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: contentHeight)
            .padding()
            .background(Color.background)
            .cornerRadius(12)
            .animation(.easeInOut(duration: 0.5))
        }
        .padding()
    }
}


struct AddProfileView: View {
    var body: some View {
        HStack {
            Image("plus")
                .frame(width: 48, height: 48)
            AnytypeText("Add profile", style: .uxBodyRegular)
                .foregroundColor(.textSecondary)
        }
    }
}


private struct ProfileNameView: View {
    @ObservedObject var viewModel: ProfileNameViewModel
    
    var body: some View {
        HStack {
            UserIconView(icon: viewModel.userIcon)
                .frame(width: 80, height: 80)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(viewModel.name, style: .uxBodyRegular)
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, 3)
                HStack {
                    Image("uploaded")
                        .clipShape(Circle())
                    AnytypeText(viewModel.peers ?? "no peers", style: .uxBodyRegular)
                        .foregroundColor(!viewModel.peers.isNil ? .textPrimary : .textSecondary)
                }
            }
            Spacer(minLength: 10).frame(minWidth: 10, maxWidth: nil)
        }
    }
}

struct SelectProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel =  SelectProfileViewModel()
        let profile1 = ProfileNameViewModel(id: "1")
        profile1.name = "Anton Pronkin"
        let profile2 = ProfileNameViewModel(id: "2")
        profile2.name = "James Simon"
        profile2.image = UIImage(named: "logo")
        let profile3 = ProfileNameViewModel(id: "3")
        profile3.name = "Tony Leung"
        viewModel.profilesViewModels = [profile1, profile2]
        
        return SelectProfileView(viewModel: viewModel)
    }
}
