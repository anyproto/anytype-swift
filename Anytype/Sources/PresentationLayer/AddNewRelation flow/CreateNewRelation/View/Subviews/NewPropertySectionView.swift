import SwiftUI

struct NewPropertySectionView<Content: View>: View {
    
    let title: String
    @ViewBuilder
    let contentViewBuilder: () -> Content
    let onTap: (() -> Void)?
    let isArrowVisible: Bool
    
    var body: some View {
        Group {
            if let onTap = onTap {
                Button { onTap() } label: { label }.divider()
            } else {
                label.divider()
            }
        }
    }
    
    private var label: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                titleView
                contentViewBuilder()
            }
            
            Spacer()
            
            if isArrowVisible {
                Image(asset: .RightAttribute.disclosure)
            }
        }
        .frame(height: 68)
    }
    
    private var titleView: some View {
        AnytypeText(title, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
            .lineLimit(1)
    }
    
}
