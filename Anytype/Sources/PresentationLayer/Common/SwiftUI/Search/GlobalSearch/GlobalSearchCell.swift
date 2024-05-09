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
            
            AnytypeText(data.title, style: .previewTitle2Regular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            highlights
            
            if data.objectTypeName.isNotEmpty {
                AnytypeText(data.objectTypeName, style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
            }
            
            Spacer.fixedHeight(8)
        }
    }
    
    private var highlights: some View {
        ForEach(data.highlights) { data in
            switch data {
            case .text(let text):
                Text(text)
                    .anytypeStyle(.relation2Regular)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}
