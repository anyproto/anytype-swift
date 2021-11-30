import SwiftUI

struct DateRelationRowView: View {
    
    let value: DateRelationEditingValue
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer.fixedHeight(12)
            HStack(spacing: 0) {
                AnytypeText(value.title, style: .uxBodyRegular, color: .grayscale90)
                Spacer()
            }
            Spacer.fixedHeight(12)
        }
        .modifier(DividerModifier(spacing: 0))
    }
}

struct DateRelationRowView_Previews: PreviewProvider {
    static var previews: some View {
        DateRelationRowView(value: .noDate, isSelected: false)
            .background(Color.purple.opacity(0.2))
    }
}
