import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import SwiftUI

final class SetFiltersSearchViewBuilder {
    let filter: SetFilter
    
    init(filter: SetFilter) {
        self.filter = filter
    }
    
    @ViewBuilder
    func buildSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        switch filter.metadata.format {
        case .tag:
            buildTagsSearchView(onSelect: onSelect)
        case .object:
            buildObjectSearchView(onSelect: onSelect)
        default:
            EmptyView()
        }
    }
    
    // MARK: - Private methods
    
    private func buildTagsSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        let allTags = filter.metadata.selections.map { Relation.Tag.Option(option: $0) }
        
        let selectedTagIds: [String] = {
            let selectedTagIds: [String] = filter.filter.value.listValue.values.compactMap {
                let tagId = $0.stringValue
                return tagId.isEmpty ? nil : tagId
            }
            
            return selectedTagIds.compactMap { id in
                allTags.first { $0.id == id }?.id
            }
        }()
        return NewSearchModuleAssembly.tagsSearchModule(
            style: .embedded,
            allTags: allTags,
            selectedTagIds: selectedTagIds,
            onSelect: onSelect,
            onCreate: { _ in }
        )
    }
    
    private func buildObjectSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        let selectedObjects: [String] = {
            let value = filter.filter.value
            let values: [Google_Protobuf_Value] = {
                if case let .listValue(listValue) = value.kind {
                    return listValue.values
                }
                
                return [value]
            }()
            
            return values.map { $0.stringValue }
        }()
        return NewSearchModuleAssembly.objectsSearchModule(
            style: .embedded,
            excludedObjectIds: selectedObjects,
            limitedObjectType: [],
            onSelect: onSelect
        )
    }
}
