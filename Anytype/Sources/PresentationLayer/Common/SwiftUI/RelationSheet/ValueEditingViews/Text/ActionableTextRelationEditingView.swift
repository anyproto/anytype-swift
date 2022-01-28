import SwiftUI

struct ActionableTextRelationEditingView: View {
    
    @ObservedObject var viewModel: ActionableTextRelationEditingViewModel
    @State private var height: CGFloat = 0
    
    var body: some View {
        textView
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .modifier(RelationSheetModifier(isPresented: $viewModel.isPresented, title: viewModel.title, dismissCallback: viewModel.onDismiss))
    }
    
    private var textView: some View {
        HStack(spacing: 8) {
            RelationTextView(text: $viewModel.value, placeholder: viewModel.placeholder, keyboardType: viewModel.keyboardType)
            
            if let icon = viewModel.icon, viewModel.value.isNotEmpty, viewModel.isActionButtonEnabled {
                Button {
                    viewModel.performAction()
                } label: {
                    icon
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.strokePrimary, lineWidth: 1)
                        )
                }
            }
        }
    }
    
}

//struct ActionableTextRelationEditingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionableTextRelationEditingView()
//    }
//}
