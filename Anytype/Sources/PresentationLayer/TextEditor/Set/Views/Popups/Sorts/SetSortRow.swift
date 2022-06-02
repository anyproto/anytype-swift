import SwiftUI
import BlocksModels

struct SetSortRow: View {
    
    let sort: SetSort
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            content
        }
    }
    
    private var content: some View {
        HStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.backgroundSelected)
                Image.createImage(sort.metadata.format.iconName)
            }
            .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(sort.metadata.name, style: .uxTitle2Medium, color: .textPrimary)
                AnytypeText(sort.type, style: .relation1Regular, color: .textSecondary)
            }
            
            Spacer()
            
            Image.arrow
        }
        .frame(height: 68)
    }
}
