import Services
import SwiftUI
import Foundation
import AnytypeCore

@MainActor
protocol SearchWithMetaModelBuilderProtocol {
    func buildModel(with searchResult: SearchResultWithMeta, spaceId: String, participantCanEdit: Bool) -> SearchWithMetaModel
}

@MainActor
final class SearchWithMetaModelBuilder: SearchWithMetaModelBuilderProtocol {
    
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    nonisolated init() { }
    
    func buildModel(with searchResult: SearchResultWithMeta, spaceId: String, participantCanEdit: Bool) -> SearchWithMetaModel {
        
        let details = searchResult.objectDetails
        let meta = searchResult.meta
        
        let title = buildHighlightedTitle(from: meta) ?? AttributedString(details.pluralTitle)
        
        let highlights = buildHighlightsData(with: meta, spaceId: spaceId)
        
        // just for debug
        var score = ""
        if FeatureFlags.showGlobalSearchScore, let scoreDouble = details.values["_score"]?.safeDoubleValue {
            score = "\(scoreDouble)"
        }
        
        return SearchWithMetaModel(
            id: details.id,
            iconImage: details.objectIconImage,
            title: title,
            highlights: highlights,
            objectTypeName: details.objectType.displayName,
            editorScreenData: ScreenData(details: details, blockId: meta.first?.blockID),
            score: score,
            canArchive: details.permissions(participantCanEdit: participantCanEdit).canArchive
        )
    }
    
    private func buildHighlightedTitle(from meta: [SearchMeta]) -> AttributedString? {
        let nameMeta = meta.first { item in
            item.relationKey == BundledPropertyKey.pluralName.rawValue
        }
        
        guard let nameMeta else { return nil }
        
        return attributedString(for: nameMeta)
    }
    
    private func buildHighlightsData(with meta: [SearchMeta], spaceId: String) -> [HighlightsData] {
        meta.compactMap { [weak self] item -> HighlightsData? in
            guard let self else { return nil }
            if item.blockID.isNotEmpty {
                return buildTextBlockHighlights(with: item)
            } else if item.relationKey.isNotEmpty {
                return buildPropertyData(with: item, spaceId: spaceId)
            } else {
                return nil
            }
        }
    }
    
    private func buildPropertyData(with meta: SearchMeta, spaceId: String) -> HighlightsData? {
        guard meta.relationKey != BundledPropertyKey.name.rawValue && meta.relationKey != BundledPropertyKey.pluralName.rawValue else {
            return nil
        }
        
        guard let relationDetails = try? propertyDetailsStorage.relationsDetails(key: meta.relationKey, spaceId: spaceId) else {
            return nil
        }
        
        switch relationDetails.format {
        case .longText, .shortText:
            return textHighlightsData(with: relationDetails, meta: meta)
        case .status:
            guard let details = meta.relationDetails.asDetails else { return nil }
            let option = PropertyOption(details: details)
            let relationStatusOption = Relation.Status.Option(option: option)
            return .status(name: relationDetails.name, option: relationStatusOption)
        case .tag:
            guard let details = meta.relationDetails.asDetails else { return nil }
            let option = PropertyOption(details: details)
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
    var searchWithMetaModelBuilder: Factory<any SearchWithMetaModelBuilderProtocol> {
        self { SearchWithMetaModelBuilder() }.shared
    }
}
