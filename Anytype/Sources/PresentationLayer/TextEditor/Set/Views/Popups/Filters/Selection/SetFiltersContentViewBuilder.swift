import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import SwiftUI

final class SetFiltersContentViewBuilder {
    let filter: SetFilter
    
    init(filter: SetFilter) {
        self.filter = filter
    }
    
    @ViewBuilder
    func buildContentView(
        router: EditorRouterProtocol,
        setSelectionModel: SetFiltersSelectionViewModel,
        onSelect: @escaping (_ ids: [String]) -> Void,
        onApplyText: @escaping (_ text: String) -> Void,
        onApplyCheckbox: @escaping (Bool) -> Void,
        onApplyDate: @escaping (SetFiltersDate) -> Void,
        onKeyboardHeightChange: @escaping (_ height: CGFloat) -> Void
    ) -> some View {
        switch filter.conditionType {
        case let .selected(format):
            buildSearchView(with: format, onSelect: onSelect)
        case .text, .number:
            buildTextView(onApplyText: onApplyText, onKeyboardHeightChange: onKeyboardHeightChange)
        case .checkbox:
            buildCheckboxView(onApplyCheckbox: onApplyCheckbox)
        case .date:
            buildDateView(router: router, setSelectionModel: setSelectionModel, onApplyDate: onApplyDate)
        }
    }
    
    // MARK: - Private methods: Search
    
    @ViewBuilder
    private func buildSearchView(
        with format: RelationFormat,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        switch format {
        case .tag:
            buildTagsSearchView(onSelect: onSelect)
        case .object:
            buildObjectsSearchView(onSelect: onSelect)
        case .status:
            buildStatusesSearchView(onSelect: onSelect)
        default:
            EmptyView()
        }
    }
    
    private func buildTagsSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        #warning("fix options")
//        let allTags = filter.relationDetails.selections.map { Relation.Tag.Option(option: $0) }
        let allTags = [Relation.Tag.Option]()
        let selectedTagIds = selectedIds(
            from: filter.filter.value,
            allOptions: allTags.map { $0.id }
        )
        return NewSearchModuleAssembly.tagsSearchModule(
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedTagIds),
            relationKey: filter.relationDetails.key,
            selectedTagIds: [],
            onSelect: onSelect,
            onCreate: { _ in }
        )
    }
    
    private func buildObjectsSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        let selectedObjectsIds: [String] = {
            let value = filter.filter.value
            let values: [Google_Protobuf_Value] = {
                if case let .listValue(listValue) = value.kind {
                    return listValue.values
                }
                
                return [value]
            }()
            return values.map { $0.stringValue }
        }()
        #warning("Check limitedObjectType")
        return NewSearchModuleAssembly.objectsSearchModule(
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedObjectsIds),
            excludedObjectIds: [],
            limitedObjectType: filter.relationDetails.objectTypes,
            onSelect: onSelect
        )
    }
    
    private func buildStatusesSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        #warning("Fix selections")
//        let allStatuses = filter.relationDetails.selections.map { Relation.Status.Option(option: $0) }
        let allStatuses = [Relation.Status.Option]()
        let selectedStatusesIds = selectedIds(
            from: filter.filter.value,
            allOptions: allStatuses.map { $0.id }
        )
        return NewSearchModuleAssembly.statusSearchModule(
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedStatusesIds),
            allStatuses: allStatuses,
            selectedStatusesIds: [],
            onSelect: onSelect,
            onCreate: { _ in }
        )
    }
    
    // MARK: - Private methods: Text
    
    func buildTextView(
        onApplyText: @escaping (_ text: String) -> Void,
        onKeyboardHeightChange: @escaping (_ height: CGFloat) -> Void
    ) -> some View {
        SetFiltersTextView(
            viewModel: SetFiltersTextViewModel(
                filter: filter,
                onApplyText: onApplyText,
                onKeyboardHeightChange: onKeyboardHeightChange
            )
        )
    }
    
    // MARK: - Private methods: Checkbox
    
    func buildCheckboxView(
        onApplyCheckbox: @escaping (Bool) -> Void
    ) -> some View {
        SetFiltersCheckboxView(
            viewModel: SetFiltersCheckboxViewModel(
                filter: filter,
                onApplyCheckbox: onApplyCheckbox
            )
        )
    }
    
    // MARK: - Private methods: Date
    
    func buildDateView(
        router: EditorRouterProtocol,
        setSelectionModel: SetFiltersSelectionViewModel,
        onApplyDate: @escaping (SetFiltersDate) -> Void
    ) -> some View {
        SetFiltersDateView(
            viewModel: SetFiltersDateViewModel(
                filter: filter,
                router: router,
                setSelectionModel: setSelectionModel,
                onApplyDate: onApplyDate
            )
        )
    }
    
    // MARK: - Helper methods
    
    private func selectedIds(
        from value: SwiftProtobuf.Google_Protobuf_Value,
        allOptions: [String]
    ) -> [String] {
        let selectedIds: [String] = value.listValue.values.compactMap {
            let value = $0.stringValue
            return value.isEmpty ? nil : value
        }
        
        return selectedIds.compactMap { id in
            allOptions.first { $0 == id }
        }
    }
}
