import SwiftUI
import AnytypeCore
import BlocksModels

struct SearchCell<SearchData: SearchDataProtocol>: View {
    
    let data: SearchData

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
            Spacer.fixedWidth(12)
            content
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 16)
    }
    
    private var icon: some View {
        SwiftUIObjectIconImageView(iconImage: data.iconImage, usecase: data.usecase)
            .frame(width: 48, height: 48)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            AnytypeText(data.title, style: .previewTitle2Medium, color: .TextNew.primary)
                .lineLimit(1)
                .frame(height: 20)
            
            if data.shouldShowDescription {
                Spacer.fixedHeight(1)
                AnytypeText(data.description, style: data.descriptionFont, color: data.descriptionTextColor)
                    .lineLimit(1)
            }
            
            if data.shouldShowCallout {
                Spacer.fixedHeight(2)
                AnytypeText(data.callout, style: .relation2Regular, color: .TextNew.secondary)
                .lineLimit(1)
            }
            
            Spacer()
            AnytypeDivider()
        }
    }
    
}
