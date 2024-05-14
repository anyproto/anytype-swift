import Services
import Foundation
import AnytypeCore

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
        
        // just for debug
        var score = ""
        if FeatureFlags.showGlobalSearchScore, let scoreDouble = details.values["_score"]?.safeDoubleValue {
            score = "\(scoreDouble)"
        }
        
        return GlobalSearchData(
            iconImage: details.objectIconImage,
            title: details.title,
            highlights: highlights,
            objectTypeName: details.objectType.name,
            backlinks: details.backlinks,
            editorScreenData: EditorScreenData(details: details, blockId: meta.first?.blockID),
            score: score
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
        guard item.relationKey != BundledRelationKey.name.rawValue else {
            return nil
        }
        
        guard let relationDetails = try? relationDetailsStorage.relationsDetails(for: item.relationKey, spaceId: workspaceInfo.accountSpaceId) else {
            return nil
        }
        
        switch relationDetails.format {
        case .longText, .shortText:
            let highlight = item.highlight.replacingMarksWithBackgroundHighlight
            return textHighlightsData(with: relationDetails, highlight: highlight)
        case .status:
            guard let details = item.relationDetails.asDetails else { return nil }
            let option = RelationOption(details: details)
            let relationStatusOption = Relation.Status.Option(option: option)
            return .status(name: relationDetails.name, option: relationStatusOption)
        case .tag:
            guard let details = item.relationDetails.asDetails else { return nil }
            let option = RelationOption(details: details)
            let relationTagOption = Relation.Tag.Option(option: option)
            return .tag(name: relationDetails.name, option: relationTagOption)
        default:
            let highlight = item.highlight.removeMarks
            return textHighlightsData(with: relationDetails, highlight: highlight)
        }
    }
    
    private func textHighlightsData(with relationDetails: RelationDetails, highlight: String) -> HighlightsData? {
        guard highlight.isNotEmpty else { return nil }
        let text = relationDetails.name + ": " + highlight
        let attrText = text.customMarkdownAttributedString.annotateCustomAttributes
        return .text(attrText)
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
