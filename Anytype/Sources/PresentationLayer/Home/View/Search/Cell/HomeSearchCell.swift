import SwiftUI
import AnytypeCore

struct HomeSearchCell: View {
    let data: HomeSearchCellData
    
    private var haveDescription: Bool {
        guard let description = data.description else {
            return false
        }
        
        return description.isNotEmpty
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: data.icon,
                usecase: .dashboardSearch
            ).frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
            text
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 16)
        .background(Color.background)
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(haveDescription ? 7 : 14)
            AnytypeText(data.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
            Spacer.fixedHeight(1)
            description
            type
            Spacer.fixedHeight(haveDescription ? 7 : 14)
        }
    }
    
    private var description: some View {
        Group {
            if let descriptionText = data.description, !descriptionText.isEmpty {
                AnytypeText(descriptionText, style: .relation3Regular, color: .textPrimary)
                    .lineLimit(1)
                Spacer.fixedHeight(2)
            } else {
                EmptyView()
            }
        }
    }
    
    private var type: some View {
        AnytypeText(
            data.type,
            style: haveDescription ? .relation3Regular : .relation2Regular,
            color: .textSecondary
        )
        .lineLimit(1)
    }
}

import BlocksModels
struct HomeSearchCell_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(HomeSearchCellDataMock.data) { data in
                HomeSearchCell(data: data)
            }
        }
        .background(Color.background)
    }
}
