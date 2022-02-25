import SwiftUI


struct SelectProfileView: View {
    @StateObject var viewModel: SelectProfileViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                Gradients.mainBackground()
                ProgressView()
            }
        }
        .errorToast(isShowing: $viewModel.showError, errorText: viewModel.errorText ?? "") {
            presentationMode.wrappedValue.dismiss()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.accountRecover()
        }
    }

}

struct SelectProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel =  SelectProfileViewModel()
        return SelectProfileView(viewModel: viewModel)
    }
}
