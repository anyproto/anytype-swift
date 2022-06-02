import SwiftUI
import BlocksModels

struct SetSortRow: View {
    
    @Environment(\.editMode)  var editMode
    
    let sort: SetSort
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            content
        }
        .disabled(editMode?.wrappedValue != .inactive)
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
            
            if editMode?.wrappedValue == .inactive {
                Image.arrow
            }
        }
        .frame(height: 68)
    }
}
