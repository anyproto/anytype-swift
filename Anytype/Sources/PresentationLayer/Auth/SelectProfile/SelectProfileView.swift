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
        .navigationBarBackButtonHidden(true)
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
        return SelectProfileView(viewModel: viewModel)
    }
}
