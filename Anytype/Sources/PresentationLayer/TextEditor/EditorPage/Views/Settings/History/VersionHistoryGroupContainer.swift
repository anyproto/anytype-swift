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
        .padding(.top, 4)
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .border(12, color: .Shape.primary, lineWidth: 0.5)
    }
    
    private var header: some View {
        HStack {
            AnytypeText(title, style: .uxTitle2Regular)
                .foregroundColor(.Text.secondary)
            
            Spacer()
            
            iconsView
        }
        .padding(.vertical, 4)
        .fixTappableArea()
        .onTapGesture {
            withAnimation {
                headerAction()
            }
        }
    }
    
    private var iconsView: some View {
        HStack {
            ForEach(icons, id: \.hashValue) { icon in
                ObjectIconView(icon: icon)
                    .frame(width: 24, height: 24)
            }
        }
        .opacity(isExpanded ? 0 : 1)
    }
}
