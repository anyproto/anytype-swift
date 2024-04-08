import Foundation
import SwiftUI

struct SectionHeaderView<Content>: View where Content: View {
    let title: String
    let rightContent: () -> Content?
    
    init(title: String, @ViewBuilder rightContent: @escaping () -> Content? = { EmptyView() }) {
        self.title = title
        self.rightContent = rightContent
    }
    
    var body: some View {
        HStack(spacing: 0) {
            AnytypeText(title, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
            Spacer()
            rightContent()
        }
        .padding(.top, 26)
        .padding(.bottom, 8)
    }
}
