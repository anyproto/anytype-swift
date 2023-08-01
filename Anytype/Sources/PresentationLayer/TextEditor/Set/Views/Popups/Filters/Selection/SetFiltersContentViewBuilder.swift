import Foundation
import Services
import SwiftProtobuf
import UIKit
import SwiftUI

final class SetFiltersContentViewBuilder {
    let spaceId: String
    let filter: SetFilter
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(spaceId: String, filter: SetFilter, newSearchModuleAssembly: NewSearchModuleAssemblyProtocol) {
        self.spaceId = spaceId
        self.filter = filter
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    @ViewBuilder
    func buildContentView(
        router: EditorSetRouterProtocol,
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
        let selectedTagIds = selectedIds(
            from: filter.filter.value
        )
        return newSearchModuleAssembly.tagsSearchModule(
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedTagIds),
            spaceId: spaceId,
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
        return newSearchModuleAssembly.objectsSearchModule(
            spaceId: spaceId,
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedObjectsIds),
            excludedObjectIds: [],
            limitedObjectType: filter.relationDetails.objectTypes,
            onSelect: { details in onSelect(details.map(\.id)) }
        )
    }
    
    private func buildStatusesSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> some View {
        let selectedStatusesIds = selectedIds(
            from: filter.filter.value
        )
        return newSearchModuleAssembly.statusSearchModule(
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedStatusesIds),
            spaceId: spaceId,
            relationKey: filter.relationDetails.key,
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
        router: EditorSetRouterProtocol,
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
        from value: SwiftProtobuf.Google_Protobuf_Value
    ) -> [String] {
        let selectedIds: [String] = value.listValue.values.compactMap {
            let value = $0.stringValue
            return value.isEmpty ? nil : value
        }
        
        return selectedIds
    }
}
