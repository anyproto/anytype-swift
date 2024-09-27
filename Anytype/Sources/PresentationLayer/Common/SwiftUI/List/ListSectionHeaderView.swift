import SwiftUI

struct ListSectionHeaderView<Content>: View where Content: View {
    let title: String
    let increasedTopPadding: Bool
    let hasRightContent: Bool
    let rightContent: () -> Content
    
    init(title: String, increasedTopPadding: Bool = true, @ViewBuilder rightContent: @escaping () -> Content) {
        self.title = title
        self.increasedTopPadding = increasedTopPadding
        self.hasRightContent = true
        self.rightContent = rightContent
    }
    
    var body: some View {
        SectionHeaderView<Content>(title: title, increasedTopPadding: increasedTopPadding, rightContent: rightContent)
            .if(hasRightContent) {
                $0.divider(spacing: 0, alignment: .leading)
            }
    }
}

extension ListSectionHeaderView where Content == EmptyView {
    init(title: String, increasedTopPadding: Bool = true) {
        self.title = title
        self.increasedTopPadding = increasedTopPadding
        self.hasRightContent = false
        self.rightContent = { EmptyView() }
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
