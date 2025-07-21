import SwiftUI

struct EmbedContentData {
    let icon: ImageAsset
    let text: String
    let url: URL?
}

struct EmbedContentView: View {
    
    @ObservedObject var model: EmbedContentViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            icon
            
            AnytypeText(model.data.text, style: .relation2Regular)
                .foregroundColor(.Text.secondary)
            
            if model.data.url.isNotNil {
                StandardButton(
                    Loc.open,
                    style: .primaryXSmall,
                    action: { model.onOpenTap() }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.Shape.transperentTertiary)
        .cornerRadius(16)
        .safariSheet(url: $model.safariUrl)
    }
    
    private var icon: some View {
        Image(asset: model.data.icon)
            .frame(width: 40, height: 40)
            .background(Color.Shape.transperentSecondary)
            .cornerRadius(8)
    }
}
