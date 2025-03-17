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
        .frame(height: data.isMinimal ? 52 : 68)
        .newDivider()
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var icon: some View {
        if let iconImage = data.iconImage {
            IconView(icon: iconImage)
                .frame(width: 48, height: 48)
                .allowsHitTesting(false)
            Spacer.fixedWidth(12)
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            AnytypeText(data.title, style: .previewTitle2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
                .frame(height: 20)
            
            switch data.mode {
            case .full(let descriptionInfo, let callout):
                if let descriptionInfo {
                    Spacer.fixedHeight(1)
                    AnytypeText(descriptionInfo.description, style: descriptionInfo.descriptionFont)
                        .foregroundColor(descriptionInfo.descriptionTextColor)
                        .lineLimit(1)
                }
                
                if let callout {
                    Spacer.fixedHeight(2)
                    AnytypeText(callout, style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
                }
            case .minimal:
                EmptyView()
            }
            
            Spacer()
        }
    }
    
}
