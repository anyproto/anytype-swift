import SwiftUI


struct SelectProfileView: View {
    @StateObject var viewModel: SelectProfileViewModel
    @State private var showCreateProfileView = false
    @State private var contentHeight: CGFloat = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                Gradients.mainBackground()
                ProgressView()
            }
        }
        .errorToast(isShowing: $viewModel.showError, errorText: viewModel.error ?? "") {
            presentationMode.wrappedValue.dismiss()
        }
        .navigationBarHidden(true)
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
}


struct AddProfileView: View {
    var body: some View {
        HStack {
            Image("plus")
                .frame(width: 48, height: 48)
            AnytypeText("Add profile", style: .uxBodyRegular, color: .textSecondary)
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
                AnytypeText(viewModel.name, style: .uxBodyRegular, color: .textPrimary)
                    .padding(.bottom, 3)
                HStack {
                    Image("uploaded")
                        .clipShape(Circle())
                    AnytypeText(
                        viewModel.peers ?? "no peers",
                        style: .uxBodyRegular,
                        color: viewModel.peers.isNotNil ? .textPrimary : .textSecondary
                    )
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
