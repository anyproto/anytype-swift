import SwiftUI
import AnytypeCore
import Services

struct SearchCell<SearchData: SearchDataProtocol>: View {
    
    let data: SearchData

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
            content
            Spacer()
        }
        .frame(height: 68)
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
            Spacer()
            
            AnytypeText(data.title, style: .previewTitle2Medium, color: .Text.primary)
                .lineLimit(1)
                .frame(height: 20)
            
            if data.shouldShowDescription {
                Spacer.fixedHeight(1)
                AnytypeText(data.description, style: data.descriptionFont, color: data.descriptionTextColor)
                    .lineLimit(1)
            }
            
            if data.shouldShowCallout {
                Spacer.fixedHeight(2)
                AnytypeText(data.callout, style: .relation2Regular, color: .Text.secondary)
                .lineLimit(1)
            }
            
            Spacer()
        }
    }
    
}
