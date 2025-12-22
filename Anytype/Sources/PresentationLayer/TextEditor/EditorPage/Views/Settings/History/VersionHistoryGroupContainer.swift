import Foundation
import SwiftUI
import Services

struct VersionHistoryGroupContainer<Content>: View where Content: View {
    
    let title: String
    let icons: [ObjectIcon]
    let content: Content
    let isExpanded: Bool
    let headerAction: (() -> Void)
    
    var body: some View {
        VStack(spacing: 0) {
            header
            if isExpanded {
                content
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .border(12, color: .Shape.primary, lineWidth: 0.5)
    }
    
    private var header: some View {
        HStack {
            AnytypeText(title, style: .uxTitle2Regular)
                .foregroundStyle(Color.Text.secondary)
            
            Spacer()
            
            IconsGroupView(icons: icons)
                .opacity(isExpanded ? 0 : 1)
        }
        .padding(.vertical, 4)
        .fixTappableArea()
        .onTapGesture {
            withAnimation {
                headerAction()
            }
        }
    }
}
