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
        NewSearchModuleAssembly.tagsSearchModule(
            style: .embedded,
            allTags: filter.metadata.selections.map { Relation.Tag.Option(option: $0) },
            selectedTagIds: [],
            onSelect: onSelect,
            onCreate: { _ in }
        )
    }
    
    private func buildObjectSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        NewSearchModuleAssembly.objectsSearchModule(
            style: .embedded,
            excludedObjectIds: [],
            limitedObjectType: [],
            onSelect: onSelect
        )
    }
}
