import SwiftUI
import AnytypeCore
import Services


struct GlobalSearchCell: View {
    
    let data: GlobalSearchData

    var body: some View {
        HStack(alignment: data.highlights.isEmpty ? .center : .top, spacing: 12) {
            icon
            content
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .newDivider()
        .padding(.horizontal, 16)
        .if(data.relatedLinks.isNotEmpty) {
            $0.overlay(alignment: .trailing) {
                relationLinksIndicator
                    .offset(x: Constants.neededIndicatorWidth) // shift indicator to avoid white line blinking
            }
        }
    }
    
    private var icon: some View {
        VStack {
            Spacer.fixedHeight(8)
            IconView(icon: data.iconImage)
                .frame(width: 48, height: 48)
                .allowsHitTesting(false)
            Spacer.fixedHeight(8)
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(8)
            
            Text(data.title)
                .anytypeStyle(.previewTitle2Medium)
                .lineLimit(1)
            
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
    
    private var relationLinksIndicator: some View {
        Color.Control.active
            .frame(width: Constants.realIndicatorWidth, height: 28)
            .cornerRadius(4, style: .continuous)
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

extension GlobalSearchCell {
    enum Constants {
        static let realIndicatorWidth: CGFloat = Constants.neededIndicatorWidth * 2
        static let neededIndicatorWidth: CGFloat = 6
    }
}
