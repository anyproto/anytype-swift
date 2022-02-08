import SwiftUI

struct TextRelationEditingView: View {
            
    @ObservedObject var viewModel: TextRelationEditingViewModel
    @State private var height: CGFloat = 0
    
    var body: some View {
        RelationTextView(text: $viewModel.value, placeholder: viewModel.placeholder, keyboardType: viewModel.keyboardType)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .modifier(RelationSheetModifier(isPresented: $viewModel.isPresented, title: viewModel.title, dismissCallback: viewModel.onDismiss))
    }
    
}

struct RelationTextValueEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationEditingView(
            viewModel: TextRelationEditingViewModel(
                type: .number,
                title: "title",
                value: "vale",
                relationKey: "key",
                service: RelationsService(objectId: "")
            )
        )
            .background(Color.red)
    }
}
