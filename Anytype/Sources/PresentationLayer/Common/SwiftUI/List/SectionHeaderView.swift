import Foundation
import SwiftUI

struct SectionHeaderView<Content>: View where Content: View {
    let title: String
    let increasedTopPadding: Bool
    let rightContent: () -> Content?
    
    init(title: String, increasedTopPadding: Bool = true, @ViewBuilder rightContent: @escaping () -> Content? = { EmptyView() }) {
        self.title = title
        self.increasedTopPadding = increasedTopPadding
        self.rightContent = rightContent
    }
    
    var body: some View {
        HStack(spacing: 0) {
            AnytypeText(title, style: .caption1Regular, enableMarkdown: true)
                .foregroundColor(.Text.secondary)
                .if(rightContent().isNotNil) {
                    $0.lineLimit(1)
                }
            
            if rightContent().isNotNil {
                Spacer.init(minLength: 16)
            }
            
            rightContent()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, increasedTopPadding ? 26 : 8)
        .padding(.bottom, 8)
    }
}
