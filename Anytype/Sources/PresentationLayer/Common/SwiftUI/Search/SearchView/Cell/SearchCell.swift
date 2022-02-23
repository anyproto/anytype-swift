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
            title
            
            if data.shouldShowDescription && haveDescription {
                Spacer.fixedHeight(1)
                description
            }
            
            if data.shouldShowCallout && data.callout.isNotEmpty {
                Spacer.fixedHeight(2)
                type
            }
            
            Spacer()
            AnytypeDivider()
        }
    }
    
    private var title: some View {
        AnytypeText(data.searchTitle, style: .previewTitle2Medium, color: .textPrimary)
            .lineLimit(1)
            .frame(height: 20)
    }
    
    private var description: some View {
        AnytypeText(data.description, style: .relation3Regular, color: data.descriptionTextColor)
            .lineLimit(1)
    }
    
    private var type: some View {
        AnytypeText(
            data.callout,
            style: haveDescription ? .relation3Regular : .relation2Regular,
            color: .textSecondary
        )
        .lineLimit(1)
    }
    
    private var haveDescription: Bool {
        data.description.isNotEmpty
    }
}
