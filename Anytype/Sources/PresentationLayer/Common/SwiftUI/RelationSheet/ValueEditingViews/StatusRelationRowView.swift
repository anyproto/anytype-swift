import SwiftUI

struct StatusRelationRowView: View {
    
    let status: StatusRelationValue
    let isSelected: Bool
    
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
            
        } label: {
            HStack(spacing: 0) {
                AnytypeText(status.text, style: .relation1Regular, color: status.color.asColor)
                Spacer()
                
                if isSelected {
                    Image.optionChecked.foregroundColor(.textSecondary)
                }
            }
        }
    }
}

struct StatusRelationRowView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationRowView(status: StatusRelationValue(id: "", text: "text", color: .pureTeal), isSelected: true)
    }
}
