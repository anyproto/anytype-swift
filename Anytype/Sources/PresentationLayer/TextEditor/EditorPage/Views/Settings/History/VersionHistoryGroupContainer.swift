import Foundation
import SwiftUI
import Services

struct VersionHistoryGroupContainer<Content>: View where Content: View {
    
    let title: String
    let icons: [ObjectIcon]
    let content: Content
    let onHeaderTap: (() -> Void)
    
    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
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
        .padding(.top, 8)
        .padding(.bottom, 4)
        .fixTappableArea()
        .onTapGesture {
            onHeaderTap()
        }
    }
    
    private var iconsView: some View {
        HStack {
            ForEach(icons, id: \.hashValue) { icon in
                ObjectIconView(icon: icon)
                    .frame(width: 24, height: 24)
            }
        }
    }
}
