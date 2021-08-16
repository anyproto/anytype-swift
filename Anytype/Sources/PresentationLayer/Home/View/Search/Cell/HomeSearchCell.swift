import SwiftUI

struct HomeSearchCellData: Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let icon: DocumentIconType?
    
    init(searchResult: SearchResult) {
        self.id = searchResult.id
        self.description = searchResult.description
        self.icon = searchResult.icon
        
        if let title = searchResult.name, !title.isEmpty {
            self.title = title
        } else {
            self.title = "Untitled".localized
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
            icon
            text
        }
        .frame(height: 57)
    }
    
    private var icon: some View {
        Image.Title.TodoLayout.checkmark
    }
    
    private var text: some View {
        VStack(alignment: .leading) {
            AnytypeText(data.title, style: .body)
                .foregroundColor(.textPrimary)
                .lineLimit(1)
            description
            AnytypeText(data.type, style: .footnote)
                .foregroundColor(.textSecondary)
                .lineLimit(1)
        }
    }
    
    private var description: some View {
        Group {
            if let descriptionText = data.description {
                if !descriptionText.isEmpty {
                    AnytypeText(descriptionText, style: .footnote)
                        .foregroundColor(.primary)
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
