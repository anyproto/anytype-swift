import SwiftUI

struct StatusRelationDetailsRowView: View {
    
    @Binding var selectedStatus: Relation.Status.Option?
    let status: Relation.Status.Option
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer.fixedHeight(14)
            content
            Spacer.fixedHeight(14)
        }
        .modifier(DividerModifier(spacing: 0))
    }
    
    private var content: some View {
        Button {
            selectedStatus = selectedStatus == status ? nil : status
        } label: {
            HStack(spacing: 0) {
                AnytypeText(status.text, style: .relation1Regular, color: status.color.suColor)
                Spacer()
                
                if selectedStatus == status {
                    Image.optionChecked.foregroundColor(.textSecondary)
                }
            }
            .frame(height: 20)
        }
    }
}

//struct StatusRelationRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusRelationDetailsRowView(
//            status: Relation.Status.Option(id: "", text: "text", color: UIColor.System.teal, scope: .local),
//            isSelected: true,
//            onTap: {}
//        )
//    }
//}
