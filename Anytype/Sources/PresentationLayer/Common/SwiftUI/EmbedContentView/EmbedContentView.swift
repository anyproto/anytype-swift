import SwiftUI

struct EmbedContentData {
    let icon: ImageAsset
    let processorName: String
    let hasContent: Bool
    let url: URL?
    
    var text: String {
        if hasContent {
            return url.isNil ? Loc.Embed.Block.Content.title(processorName) : Loc.Embed.Block.Content.Url.title(processorName)
        } else {
            return Loc.Embed.Block.Empty.title(processorName)
        }
    }
}

struct EmbedContentView: View {
    
    @StateObject private var model: EmbedContentViewModel

    init(data: EmbedContentData) {
        self._model = StateObject(wrappedValue: EmbedContentViewModel(data: data))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            icon
            
            Spacer.fixedWidth(12)
            
            AnytypeText(model.data.text, style: .relation2Regular)
                .foregroundColor(.Text.secondary)
            
            if model.data.url.isNotNil {
                Spacer()
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
