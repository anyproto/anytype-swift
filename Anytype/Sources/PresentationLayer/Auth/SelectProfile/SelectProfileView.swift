import SwiftUI


struct SelectProfileView: View {
    @ObservedObject var viewModel: SelectProfileViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                Gradients.mainBackground()
                ProgressView()
            }
        }
        
        .snackbar(
            isShowing: $viewModel.snackBarData.showSnackBar,
            text: AnytypeText(viewModel.snackBarData.text, style: .uxCalloutRegular, color: .textPrimary),
            autohide: .disabled
        )
        
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
        let viewModel =  SelectProfileViewModel(windowManager: DI.makeForPreview().coordinatorsDI.windowManager)
        return SelectProfileView(viewModel: viewModel)
    }
}
