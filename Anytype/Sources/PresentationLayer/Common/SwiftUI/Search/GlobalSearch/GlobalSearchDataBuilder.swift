import Services
import SwiftUI
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
        
        let blockId = FeatureFlags.scrollToBlockFromSearch ? meta.first?.blockID : nil
        
        return GlobalSearchData(
            iconImage: details.objectIconImage,
            title: details.title,
            highlights: highlights,
            objectTypeName: details.objectType.name,
            relatedLinks: details.backlinks + details.links,
            editorScreenData: EditorScreenData(details: details, blockId: blockId),
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
    
    private func buildRelationData(with meta: SearchMeta) -> HighlightsData? {
        guard meta.relationKey != BundledRelationKey.name.rawValue else {
            return nil
        }
        
        guard let relationDetails = try? relationDetailsStorage.relationsDetails(for: meta.relationKey, spaceId: workspaceInfo.accountSpaceId) else {
            return nil
        }
        
        switch relationDetails.format {
        case .longText, .shortText:
            return textHighlightsData(with: relationDetails, meta: meta)
        case .status:
            guard let details = meta.relationDetails.asDetails else { return nil }
            let option = RelationOption(details: details)
            let relationStatusOption = Relation.Status.Option(option: option)
            return .status(name: relationDetails.name, option: relationStatusOption)
        case .tag:
            guard let details = meta.relationDetails.asDetails else { return nil }
            let option = RelationOption(details: details)
            let relationTagOption = Relation.Tag.Option(option: option)
            return .tag(name: relationDetails.name, option: relationTagOption)
        default:
            return nil
        }
    }
    
    private func buildTextBlockHighlights(with meta: SearchMeta) -> HighlightsData? {
        guard let attributedString = attributedString(for: meta) else { return nil }
        return .text(attributedString)
    }
    
    private func textHighlightsData(with relationDetails: RelationDetails, meta: SearchMeta) -> HighlightsData? {
        guard let attributedString = attributedString(for: meta) else { return nil }
        let result = AttributedString(relationDetails.name + ":") + attributedString
        return .text(result)
    }
    
    private func attributedString(for meta: SearchMeta) -> AttributedString? {
        guard meta.highlight.isNotEmpty else { return nil }
        var attrAtring = AttributedString(meta.highlight)
        for range in meta.highlightRanges where range.from < range.to  {
            let length = range.to - range.from
            if let r = Range<AttributedString.Index>(NSRange(location: Int(range.from), length: Int(length)), in: attrAtring) {
                attrAtring[r].backgroundColor = Color.Light.sky
            }
        }
        return attrAtring
    }
}

extension Container {
    var globalSearchDataBuilder: Factory<GlobalSearchDataBuilderProtocol> {
        self { GlobalSearchDataBuilder() }.shared
    }
}
