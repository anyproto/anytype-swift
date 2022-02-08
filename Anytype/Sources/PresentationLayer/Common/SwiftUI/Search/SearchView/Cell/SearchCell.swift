import SwiftUI
import AnytypeCore
import BlocksModels


struct SearchCell<SearchData: SearchDataProtocol>: View {
    let data: SearchData
    let descriptionTextColor: Color
    let shouldShowCallout: Bool
    let shouldShowDescription: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: data.iconImage,
                usecase: data.usecase
            ).frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
            text
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 16)
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(haveDescription ? 7 : 14)
            AnytypeText(data.searchTitle, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
            Spacer.fixedHeight(1)
            description
            if shouldShowCallout {
                type
            }
            Spacer.fixedHeight(haveDescription ? 7 : 14)
        }
    }
    
    private var description: some View {
        Group {
            if let descriptionText = data.description, !descriptionText.isEmpty {
                AnytypeText(
                    descriptionText,
                    style: .relation3Regular,
                    color: descriptionTextColor
                )
                    .lineLimit(1)
                Spacer.fixedHeight(2)
            } else {
                EmptyView()
            }
        }
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
