import Foundation
import Services
import SwiftProtobuf
import UIKit
import SwiftUI

final class SetFiltersContentViewBuilder {
    let filter: SetFilter
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let setFiltersDateCoordinatorAssembly: SetFiltersDateCoordinatorAssemblyProtocol
    
    init(
        filter: SetFilter,
        setFiltersDateCoordinatorAssembly: SetFiltersDateCoordinatorAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.filter = filter
        self.setFiltersDateCoordinatorAssembly = setFiltersDateCoordinatorAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    @MainActor
    func buildContentView(
        setSelectionModel: SetFiltersSelectionViewModel?,
        onSelect: @escaping (_ ids: [String]) -> Void,
        onApplyText: @escaping (_ text: String) -> Void,
        onApplyCheckbox: @escaping (Bool) -> Void,
        onApplyDate: @escaping (SetFiltersDate) -> Void,
        onKeyboardHeightChange: @escaping (_ height: CGFloat) -> Void
    ) -> AnyView {
        switch filter.conditionType {
        case let .selected(format):
            return buildSearchView(with: format, onSelect: onSelect)
        case .text, .number:
            return buildTextView(onApplyText: onApplyText, onKeyboardHeightChange: onKeyboardHeightChange)
        case .checkbox:
            return buildCheckboxView(onApplyCheckbox: onApplyCheckbox)
        case .date:
            return buildDateView(setSelectionModel: setSelectionModel, onApplyDate: onApplyDate)
        }
    }
    
    func compactPresentationMode() -> Bool {
        switch filter.conditionType {
        case .text, .number, .checkbox:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Private methods: Search
    
    private func buildSearchView(
        with format: RelationFormat,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> AnyView {
        switch format {
        case .tag:
            return buildTagsSearchView(onSelect: onSelect)
        case .object:
            return buildObjectsSearchView(onSelect: onSelect)
        case .status:
            return buildStatusesSearchView(onSelect: onSelect)
        default:
            return EmptyView().eraseToAnyView()
        }
    }
    
    private func buildTagsSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> AnyView {
        let selectedTagIds = selectedIds(
            from: filter.filter.value
        )
        return newSearchModuleAssembly.tagsSearchModule(
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedTagIds),
            relationKey: filter.relationDetails.key,
            selectedTagIds: [],
            onSelect: onSelect,
            onCreate: { _ in }
        ).eraseToAnyView()
    }
    
    private func buildObjectsSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> AnyView {
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
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedObjectsIds),
            excludedObjectIds: [],
            limitedObjectType: filter.relationDetails.objectTypes,
            onSelect: { details in onSelect(details.map(\.id)) }
        ).eraseToAnyView()
    }
    
    private func buildStatusesSearchView(
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> AnyView {
        let selectedStatusesIds = selectedIds(
            from: filter.filter.value
        )
        return newSearchModuleAssembly.statusSearchModule(
            style: .embedded,
            selectionMode: .multipleItems(preselectedIds: selectedStatusesIds),
            relationKey: filter.relationDetails.key,
            selectedStatusesIds: [],
            onSelect: onSelect,
            onCreate: { _ in }
        ).eraseToAnyView()
    }
    
    // MARK: - Private methods: Text
    
    func buildTextView(
        onApplyText: @escaping (_ text: String) -> Void,
        onKeyboardHeightChange: @escaping (_ height: CGFloat) -> Void
    ) -> AnyView {
        SetFiltersTextView(
            viewModel: SetFiltersTextViewModel(
                filter: self.filter,
                onApplyText: onApplyText,
                onKeyboardHeightChange: onKeyboardHeightChange
            )
        ).eraseToAnyView()
    }
    
    // MARK: - Private methods: Checkbox
    
    func buildCheckboxView(
        onApplyCheckbox: @escaping (Bool) -> Void
    ) -> AnyView {
        SetFiltersCheckboxView(
            viewModel: SetFiltersCheckboxViewModel(
                filter: self.filter,
                onApplyCheckbox: onApplyCheckbox
            )
        ).eraseToAnyView()
    }
    
    // MARK: - Private methods: Date
    
    @MainActor
    func buildDateView(
        setSelectionModel: SetFiltersSelectionViewModel?,
        onApplyDate: @escaping (SetFiltersDate) -> Void
    ) -> AnyView {
        setFiltersDateCoordinatorAssembly.make(filter: filter, completion: onApplyDate)
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
