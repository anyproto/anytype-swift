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
        .divider()
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
