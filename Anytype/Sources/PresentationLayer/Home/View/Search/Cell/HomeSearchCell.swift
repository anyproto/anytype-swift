import SwiftUI

struct HomeSearchCellData: Identifiable {
    let id: String
    let title: String
    let description: String?
    let type: String
    let icon: DocumentIconType?
    
    init(searchResult: SearchResult) {
        self.id = searchResult.id
        self.title = searchResult.name ?? "Untitled".localized
        self.description = searchResult.description
        self.type = searchResult.type?.name ?? "Page".localized
        self.icon = searchResult.icon
    }
}

struct HomeSearchCell: View {
    let data: HomeSearchCellData
    init(data: HomeSearchCellData) {
        self.data = data
    }
    
    var body: some View {
        HStack {
            icon
            text
        }
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
            if let description = data.description {
                AnytypeText(description, style: .footnote)
                    .foregroundColor(.primary)
                    .lineLimit(1)
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
