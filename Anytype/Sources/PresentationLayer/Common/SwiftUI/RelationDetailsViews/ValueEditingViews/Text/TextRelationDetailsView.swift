import SwiftUI

struct TextRelationDetailsView: View {
            
    @ObservedObject var viewModel: TextRelationDetailsViewModel
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(viewModel.title, style: .uxTitle1Semibold, color: .textPrimary)
                .frame(height: 48, alignment: .center)
            
            RelationTextView(text: $viewModel.value, placeholder: viewModel.placeholder, keyboardType: viewModel.keyboardType)
                
            Spacer.fixedHeight(20)
        }
        .padding(.vertical, 12)
    }
    
}

struct RelationTextValueEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationDetailsView(
            viewModel: TextRelationDetailsViewModel(
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
