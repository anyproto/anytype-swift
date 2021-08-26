import SwiftUI

struct HomeSearchCellData: Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let icon: ObjectIconImage
    
    init(searchResult: SearchResult) {
        self.id = searchResult.id
        self.description = searchResult.description
        
        let title: String = {
            if let title = searchResult.name, !title.isEmpty {
                return title
            } else {
                return "Untitled".localized
            }
        }()
        self.title = title
        
        if let layout = searchResult.layout, layout == .todo {
            self.icon = .todo(searchResult.done ?? false)
        } else {
            self.icon = searchResult.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
        }
        
        if let type = searchResult.type?.name, !type.isEmpty {
            self.type = type
        } else {
            self.type = "Page".localized
        }
    }
}

struct HomeSearchCell: View {
    let data: HomeSearchCellData
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ObjectIconImageView(
                iconImage: data.icon,
                usecase: .dashboardSearch
            ).frame(width: 48, height: 48)
            text
        }
        .frame(height: 57)
    }
    
    private var text: some View {
        VStack(alignment: .leading) {
            AnytypeText(data.title, style: .previewTitle2Medium)
                .foregroundColor(.textPrimary)
                .lineLimit(1)
            description
            AnytypeText(data.type, style: .relation3Regular)
                .foregroundColor(.textSecondary)
                .lineLimit(1)
        }
    }
    
    private var description: some View {
        Group {
            if let descriptionText = data.description {
                if !descriptionText.isEmpty {
                    AnytypeText(descriptionText, style: .relation3Regular)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                } else {
                    EmptyView()
                }
            } else {
                EmptyView()
            }
        }
    }
}

import BlocksModels
struct HomeSearchCell_Previews: PreviewProvider {
    static var previews: some View {
        HomeSearchCell(
            data: HomeSearchCellData(
                searchResult: SearchResult(fields: [DetailsKind.id.rawValue: "1"])!
            )
        )
    }
}
