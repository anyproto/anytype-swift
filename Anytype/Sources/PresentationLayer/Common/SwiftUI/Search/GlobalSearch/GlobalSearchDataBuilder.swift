import Services
import Foundation

@MainActor
protocol GlobalSearchDataBuilderProtocol {
    func buildData(with searchResult: SearchResultWithMeta) -> GlobalSearchData
}

@MainActor
final class GlobalSearchDataBuilder: GlobalSearchDataBuilderProtocol {
    nonisolated init() { }
    
    func buildData(with searchResult: SearchResultWithMeta) -> GlobalSearchData {
        
        let details = searchResult.objectDetails
        let meta = searchResult.meta
        
        let textWithHighlight = buildTextWithHighlight(with: meta)
        
        return GlobalSearchData(
            iconImage: details.objectIconImage,
            title: details.title,
            textWithHighlight: textWithHighlight,
            objectTypeName: details.objectType.name,
            backlinks: details.backlinks,
            editorScreenData: details.editorScreenData()
        )
    }
    
    private func buildTextWithHighlight(with meta: [SearchMeta]) -> AttributedString? {
        // takes only the first match for now
        guard let metaItem = meta.first, metaItem.blockID.isNotEmpty, metaItem.highlight.isNotEmpty else { return nil }
        return AttributedString(metaItem.highlight)
    }
}

extension Container {
    var globalSearchDataBuilder: Factory<GlobalSearchDataBuilderProtocol> {
        self { GlobalSearchDataBuilder() }.shared
    }
}
