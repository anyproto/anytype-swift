import SwiftUI
import AnytypeCore
import Services

struct GlobalSearchCell: View {
    
    let data: GlobalSearchData

    var body: some View {
        HStack(spacing: 0) {
            icon
            content
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .newDivider()
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var icon: some View {
        if let iconImage = data.iconImage {
            IconView(icon: iconImage)
                .frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(8)
            
            AnytypeText(data.title, style: .previewTitle2Medium)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            highlights
            
            if data.objectTypeName.isNotEmpty {
                HStack(spacing: 0) {
                    AnytypeText(data.objectTypeName, style: .relation2Regular)
                        .foregroundColor(.Text.secondary)
                        .lineLimit(1)
                    
                    if FeatureFlags.showGlobalSearchScore, data.score.isNotEmpty {
                        Spacer()
                        AnytypeText(data.score, style: .relation2Regular)
                            .foregroundColor(.Text.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer.fixedHeight(8)
        }
    }
    
    private var highlights: some View {
        ForEach(data.highlights) { data in
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
            StatusRelationView(
                options: [option],
                hint: "",
                style: .featuredRelationBlock(FeaturedRelationSettings(allowMultiLine: false))
            )
        }
    }
    
    private func tagHighlight(name : String, option: Relation.Tag.Option) -> some View {
        HStack(spacing: 4) {
            relationName(name)
            TagRelationView(
                tags: [option],
                hint: "",
                style: .featuredRelationBlock(FeaturedRelationSettings(allowMultiLine: false))
            )
        }
    }
    
    private func relationName(_ name : String) -> some View {
        AnytypeText("\(name):", style: .relation2Regular)
            .foregroundColor(.Text.primary)
            .lineLimit(1)
    }
}
