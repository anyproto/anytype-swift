import SwiftUI

struct ListSectionHeaderView<Content>: View where Content: View {
    let title: String
    let titleColor: Color
    let increasedTopPadding: Bool
    var bottomPadding: CGFloat = 12
    let hasRightContent: Bool
    let rightContent: () -> Content
    
    init(title: String, titleColor: Color = .Text.secondary, increasedTopPadding: Bool = true, bottomPadding: CGFloat = 12, @ViewBuilder rightContent: @escaping () -> Content) {
        self.title = title
        self.titleColor = titleColor
        self.increasedTopPadding = increasedTopPadding
        self.bottomPadding = bottomPadding
        self.hasRightContent = true
        self.rightContent = rightContent
    }
    
    var body: some View {
        SectionHeaderView<Content>(title: title, titleColor: titleColor, increasedTopPadding: increasedTopPadding, bottomPadding: bottomPadding, rightContent: rightContent)
            .if(hasRightContent) {
                $0.divider(spacing: 0, alignment: .leading)
            }
    }
}

extension ListSectionHeaderView where Content == EmptyView {
    init(title: String, titleColor: Color = .Text.secondary, increasedTopPadding: Bool = true, bottomPadding: CGFloat = 12) {
        self.title = title
        self.titleColor = titleColor
        self.increasedTopPadding = increasedTopPadding
        self.bottomPadding = bottomPadding
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
