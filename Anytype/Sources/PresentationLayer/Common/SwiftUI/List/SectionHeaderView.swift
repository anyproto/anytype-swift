import Foundation
import SwiftUI

struct SectionHeaderView<Content>: View where Content: View {
    let title: String
    let titleColor: Color
    let increasedTopPadding: Bool
    let hasRightContent: Bool
    let rightContent: () -> Content
    
    init(title: String, titleColor: Color = .Text.secondary, increasedTopPadding: Bool = true, @ViewBuilder rightContent: @escaping () -> Content) {
        self.title = title
        self.titleColor = titleColor
        self.increasedTopPadding = increasedTopPadding
        self.hasRightContent = true
        self.rightContent = rightContent
    }
    
    var body: some View {
        HStack(spacing: 0) {
            AnytypeText(title, style: .caption1Regular)
                .foregroundColor(titleColor)
                .if(hasRightContent) {
                    $0.lineLimit(1)
                }
            
            if hasRightContent {
                Spacer.init(minLength: 16)
            }
            
            rightContent()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, increasedTopPadding ? 26 : 8)
        .padding(.bottom, 8)
    }
}

extension SectionHeaderView where Content == EmptyView {
    init(title: String, titleColor: Color = .Text.secondary, increasedTopPadding: Bool = true) {
        self.title = title
        self.titleColor = titleColor
        self.increasedTopPadding = increasedTopPadding
        self.hasRightContent = false
        self.rightContent = { EmptyView() }
    }
}
