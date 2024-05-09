import Services
import Foundation

@MainActor
protocol GlobalSearchDataBuilderProtocol {
    func buildData(with searchResult: SearchResultWithMeta) -> GlobalSearchData
}

@MainActor
final class GlobalSearchDataBuilder: GlobalSearchDataBuilderProtocol {
    
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: RelationDetailsStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    private lazy var workspaceInfo: AccountInfo = activeWorkspaceStorage.workspaceInfo
    
    nonisolated init() { }
    
    func buildData(with searchResult: SearchResultWithMeta) -> GlobalSearchData {
        
        let details = searchResult.objectDetails
        let meta = searchResult.meta
        
        let highlights = buildHighlightsData(with: meta)
        
        return GlobalSearchData(
            iconImage: details.objectIconImage,
            title: details.title,
            highlights: highlights,
            objectTypeName: details.objectType.name,
            backlinks: details.backlinks,
            editorScreenData: details.editorScreenData()
        )
    }
    
    private func buildHighlightsData(with meta: [SearchMeta]) -> [HighlightsData] {
        meta.compactMap { [weak self] item -> HighlightsData? in
            guard let self else { return nil }
            if item.blockID.isNotEmpty {
                return buildTextBlockHighlights(with: item)
            } else if item.relationKey.isNotEmpty {
                return buildRelationData(with: item)
            } else {
                return nil
            }
        }
    }
    
    private func buildTextBlockHighlights(with item: SearchMeta) -> HighlightsData? {
        guard item.highlight.isNotEmpty else { return nil }
        let text = item.highlight.replacingMarksWithBackgroundHighlight
        let attrText = text.customMarkdownAttributedString.annotateCustomAttributes
        return .text(attrText)
    }
    
    private func buildRelationData(with item: SearchMeta) -> HighlightsData? {
        guard item.relationKey != BundledRelationKey.name.rawValue, item.highlight.isNotEmpty else {
            return nil
        }
        if let relationDetails = try? relationDetailsStorage.relationsDetails(for: item.relationKey, spaceId: workspaceInfo.accountSpaceId) {
            
            let highlight: String
            switch relationDetails.format {
            case .longText, .shortText:
                highlight = item.highlight.replacingMarksWithBackgroundHighlight
            default:
                highlight = item.highlight.removeMarks
            }
            
            let text = relationDetails.name + ": " + highlight
            let attrText = text.customMarkdownAttributedString.annotateCustomAttributes
            return .text(attrText)
        } else {
            return nil
        }
    }
}

enum GlobalSearchDataTag {
    static let start = "<mark>"
    static let end = "</mark>"
}

private extension String {
    var replacingMarksWithBackgroundHighlight: String {
        replacingOccurrences(of: GlobalSearchDataTag.start, with: BackgroundHighlightAttributeSkyTag.start)
            .replacingOccurrences(of: GlobalSearchDataTag.end, with: BackgroundHighlightAttributeSkyTag.end)
    }

    var removeMarks: String {
        replacingOccurrences(of: GlobalSearchDataTag.start, with: "")
            .replacingOccurrences(of: GlobalSearchDataTag.end, with: "")
    }
    
    var customMarkdownAttributedString: AttributedString {
        (try? AttributedString(
            markdown: self,
            including: AttributeScopes.CustomAttributes.self,
            options: AttributedString.MarkdownParsingOptions(allowsExtendedAttributes: true))
        ) ?? AttributedString(self)
    }
}

extension Container {
    var globalSearchDataBuilder: Factory<GlobalSearchDataBuilderProtocol> {
        self { GlobalSearchDataBuilder() }.shared
    }
}
