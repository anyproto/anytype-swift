import SwiftUI
import AnytypeCore
import Services

struct GlobalSearchCell: View {
    
    let data: GlobalSearchData

    var body: some View {
        HStack(spacing: 0) {
            icon
            content
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .newDivider()
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var icon: some View {
        if let iconImage = data.iconImage {
            IconView(icon: iconImage)
                .frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(8)
            
            AnytypeText(data.title, style: .previewTitle2Medium, color: .Text.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            if data.description.isNotEmpty {
                AnytypeText(data.description, style: .relation2Regular, color: .Text.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            if data.objectTypeName.isNotEmpty {
                AnytypeText(data.objectTypeName, style: .relation2Regular, color: .Text.secondary)
                    .lineLimit(1)
            }
            
            Spacer.fixedHeight(8)
        }
    }
}
