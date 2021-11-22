
import SwiftUI

struct SetTableViewRow: View {
    let data: SetTableViewRowData
    let initialOffset: CGFloat
    let xOffset: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(18)
            
            AnytypeText("🚀 " + data.title, style: .body, color: .grayscale90)
                .padding(.horizontal, 16)
                .offset(x: initialOffset >= xOffset ? initialOffset - xOffset : 0, y: 0)
            Spacer.fixedHeight(18)
            HStack(spacing: 0) {
                ForEach(data.relations) { colum in
                    AnytypeText(colum.value, style: .relation2Regular, color: .textPrimary)
                        .frame(width: 144)
                    Rectangle()
                        .frame(width: 0.5, height: 18)
                        .foregroundColor(.grayscale30)
                }
            }
            
            Spacer.fixedHeight(12)
            Divider()
        }
    }
}

struct SetTableViewRow_Previews: PreviewProvider {
    static var previews: some View {
        SetTableViewRow(
            data: SetTableViewRowData(id: "", title: "Title", allRelations: [], colums: []),
            initialOffset: 0,
            xOffset: 0
        )
    }
}
