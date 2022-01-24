import SwiftUI

struct TextRelationDetailsView: View {
            
    @ObservedObject var viewModel: TextRelationDetailsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(viewModel.title, style: .uxTitle1Semibold, color: .textPrimary)
                .frame(height: 48, alignment: .center)
            
            RelationTextView(text: $viewModel.value, placeholder: viewModel.type.placeholder, keyboardType: viewModel.type.keyboardType)
                
            Spacer.fixedHeight(20)
        }
        .padding(.vertical, 12)
    }
    
}

//struct RelationTextValueEditingView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextRelationDetailsView(
//            viewModel: TextRelationDetailsViewModel(
//                value: "vale",
//                type: .number,
//                relation: .text(Relation.Text(id: "id", name: "name", isFeatured: false, isEditable: true, value: "value")),
//                service: TextRelationDetailsService(service: RelationsService(objectId: ""))
//            )
//        )
//            .background(Color.red)
//    }
//}
