
import SwiftUI

struct SetTableViewRow: View {
    let data: SetTableViewRowData
    let initialOffset: CGFloat
    let xOffset: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(18)
            title
            Spacer.fixedHeight(18)
            cells
            Spacer.fixedHeight(12)
            Divider()
        }
    }
    
    private var title: some View {
        HStack(spacing: 0) {
            if let icon = data.icon {
                SwiftUIObjectIconImageView(iconImage: icon, usecase: .setRow).frame(width: 18, height: 18)
                Spacer.fixedWidth(8)
            }
            AnytypeText(data.title, style: .body, color: .grayscale90)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .offset(x: initialOffset >= xOffset ? initialOffset - xOffset : 0, y: 0)
    }
    
    private var cells: some View {
        HStack(spacing: 0) {
            ForEach(data.relations) { colum in
                Spacer.fixedWidth(16)
                cell(colum)
                Rectangle()
                    .frame(width: 0.5, height: 18)
                    .foregroundColor(.grayscale30)
            }
        }
    }
    
    private func cell(_ data: SetRowRelation) -> some View {
        Group {
            switch data.value.value {
            case .checkbox, .number, .status, .tag, .object:
                AnytypeText("unsupported 👺", style: .relation2Regular, color: .textPrimary)
                    .lineLimit(1)
                    .frame(width: 128)
            case .text(let text), .date(let text), .phone(let text), .email(let text), .url(let text):
                AnytypeText(text ?? "", style: .relation2Regular, color: .textPrimary)
                    .lineLimit(1)
                    .frame(width: 128)
            case .unknown(let text):
                AnytypeText(text, style: .relation2Regular, color: .textPrimary)
                    .lineLimit(1)
                    .frame(width: 128)
            }
        }
    }
}

struct SetTableViewRow_Previews: PreviewProvider {
    static var previews: some View {
        SetTableViewRow(
            data: SetTableViewRowData(id: "", title: "Title", icon: .placeholder("f"), allRelations: [], colums: []),
            initialOffset: 0,
            xOffset: 0
        )
    }
}
