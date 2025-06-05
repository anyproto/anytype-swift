import SwiftUI
import AnytypeCore
import Services


struct SearchWithMetaCell: View {
    
    let model: SearchWithMetaModel

    var body: some View {
        HStack(alignment: model.highlights.isEmpty ? .center : .top, spacing: 12) {
            icon
            content
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .newDivider()
        .padding(.horizontal, 16)
    }
    
    private var icon: some View {
        VStack {
            Spacer.fixedHeight(8)
            IconView(icon: model.iconImage)
                .frame(width: 48, height: 48)
                .allowsHitTesting(false)
            Spacer.fixedHeight(8)
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(8)
            
            Text(model.title)
                .anytypeStyle(.previewTitle2Medium)
                .lineLimit(1)
            
            highlights
            
            if model.objectTypeName.isNotEmpty {
                HStack(spacing: 0) {
                    AnytypeText(model.objectTypeName, style: .relation2Regular)
                        .foregroundColor(.Text.secondary)
                        .lineLimit(1)
                    
                    if FeatureFlags.showGlobalSearchScore, model.score.isNotEmpty {
                        Spacer()
                        AnytypeText(model.score, style: .relation2Regular)
                            .foregroundColor(.Text.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer.fixedHeight(8)
        }
    }
    
    private var highlights: some View {
        ForEach(model.highlights) { data in
            switch data {
            case .text(let text):
                textHighlight(text: text)
            case .status(let name, let option):
                statusHighlight(name: name, option: option)
            case .tag(let name, let option):
                tagHighlight(name: name, option: option)
            }
        }
    }
    
    private func textHighlight(text : AttributedString) -> some View {
        Text(text)
            .anytypeStyle(.relation2Regular)
            .multilineTextAlignment(.leading)
    }
    
    private func statusHighlight(name : String, option: Relation.Status.Option) -> some View {
        HStack(spacing: 4) {
            relationName(name)
            StatusPropertyView(
                options: [option],
                hint: "",
                style: .featuredBlock(FeaturedPropertySettings(allowMultiLine: false))
            )
        }
    }
    
    private func tagHighlight(name : String, option: Relation.Tag.Option) -> some View {
        HStack(spacing: 4) {
            relationName(name)
            TagPropertyView(
                tags: [option],
                hint: "",
                style: .featuredBlock(FeaturedPropertySettings(allowMultiLine: false))
            )
        }
    }
    
    private func relationName(_ name : String) -> some View {
        AnytypeText("\(name):", style: .relation2Regular)
            .foregroundColor(.Text.primary)
            .lineLimit(1)
    }
}
