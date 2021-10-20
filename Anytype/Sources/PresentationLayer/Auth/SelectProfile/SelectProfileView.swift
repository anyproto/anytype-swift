import SwiftUI


struct SelectProfileView: View {
    @StateObject var viewModel: SelectProfileViewModel
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
