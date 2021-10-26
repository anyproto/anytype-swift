import SwiftUI
import AnytypeCore
import BlocksModels

struct SearchCell: View {
    let data: SearchData
    
    private var haveDescription: Bool {
        data.description.isNotEmpty
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: data.searchIcon,
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
            AnytypeText(data.searchTitle, style: .previewTitle2Medium, color: .textPrimary)
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
            data.searchType,
            style: haveDescription ? .relation3Regular : .relation2Regular,
            color: .textSecondary
        )
        .lineLimit(1)
    }
}

private extension SearchData {
    
    var searchTitle: String {
        self.name.isEmpty ? "Untitled".localized : self.name
    }
    
    var searchIcon: ObjectIconImage {
        let layout = self.layout
        if layout == .todo {
            return .todo(self.isDone)
        } else {
            return self.icon.flatMap { .icon($0) } ?? .placeholder(searchTitle.first)
        }
    }
    
    var searchType: String {
        if let type = self.objectType?.name, !type.isEmpty {
            return type
        } else {
            return "Page".localized
        }
    }
    
}
