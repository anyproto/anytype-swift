import SwiftUI

struct ListSectionHeaderView<Content>: View where Content: View {
    let title: String
    let rightContent: () -> Content?
    
    init(title: String, @ViewBuilder rightContent: @escaping () -> Content? = { EmptyView() }) {
        self.title = title
        self.rightContent = rightContent
    }
    
    var body: some View {
        SectionHeaderView(title: title, rightContent: rightContent)
            .divider(spacing: 0, alignment: .leading)
    }
}

#Preview("SectionHeader") {
    ListSectionHeaderView(title: "Title")
}

#Preview("SectionHeader with clear button") {
    ListSectionHeaderView(title: "Title") {
        Button(Loc.clear, action: {})
    }
}
