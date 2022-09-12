import SwiftUI

struct StatusRelationDetailsRowView: View {
    
    @Binding var selectedStatus: RelationValue.Status.Option?
    let status: RelationValue.Status.Option
    
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
                    Image(asset: .optionChecked).foregroundColor(.textSecondary)
                }
            }
            .frame(height: 20)
        }
    }
}
