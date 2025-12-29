import Foundation
import SwiftUI

@MainActor
@Observable
final class LegacySearchViewModel {

    let title: String?
    let searchPlaceholder: String
    let style: LegacySearchView.Style
    let focusedBar: Bool

    private(set) var state: LegacySearchViewState = .resultsList(.plain(rows: []))
    private(set) var addButtonModel: LegacySearchView.AddButtonModel? = nil
    private(set) var createButtonModel: CreateButtonModel = .disabled

    @ObservationIgnored
    private let itemCreationMode: ItemCreationMode
    @ObservationIgnored
    private let selectionMode: SelectionMode
    @ObservationIgnored
    private let internalViewModel: any NewInternalSearchViewModelProtocol

    @ObservationIgnored
    private var searchTask: Task<(), Never>?

    private var selectedRowIds: [String] = [] {
        didSet {
            updateAddButtonModel()
        }
    }
    
    init(
        title: String? = nil,
        searchPlaceholder: String = Loc.search,
        focusedBar: Bool = true,
        style: LegacySearchView.Style = .default,
        itemCreationMode: ItemCreationMode,
        selectionMode: SelectionMode = .multipleItems(),
        internalViewModel: some NewInternalSearchViewModelProtocol
    ) {
        self.title = title
        self.searchPlaceholder = searchPlaceholder
        self.focusedBar = focusedBar
        self.style = style
        self.itemCreationMode = itemCreationMode
        self.selectionMode = selectionMode
        self.internalViewModel = internalViewModel
        setup()
    }
}

extension LegacySearchViewModel {
    
    func didAskToSearch(text: String) {
        searchTask?.cancel()
        
        searchTask = Task { @MainActor in
            try? await internalViewModel.search(text: text)
            updateCreateItemButtonState(searchText: text)
        }
    }
    
    func didSelectRow(with id: String) {
        switch internalViewModel.selectionMode {
        case .singleItem:
            internalViewModel.handleConfirmSelection(ids: [id])
        case .multipleItems:
            handleMultipleRowsSelection(rowId: id)
        }
    }
    
    func didTapCreateButton(title: String) {
        guard case .available(let action) = itemCreationMode else { return }
        action(title)
    }
    
    func didTapAddButton() {
        internalViewModel.handleConfirmSelection(ids: selectedRowIds)
    }
    
}

private extension LegacySearchViewModel {
    
    func setup() {
        setupInternalViewModel()
        updateCreateItemButtonState(searchText: "")
        updateSelectedRowIds()
        updateAddButtonModel()
    }
    
    func setupInternalViewModel() {
        Task { @MainActor [weak self, internalViewModel] in
            for await state in internalViewModel.viewStatePublisher.values {
                self?.state = state
            }
        }
    }
    
    func updateCreateItemButtonState(searchText: String) {
        guard case .available = itemCreationMode else {
            return
        }
        
        createButtonModel = internalViewModel.createButtonModel(searchText: searchText)
    }
    
    func updateSelectedRowIds() {
        if case let .multipleItems(preselectedIds) = selectionMode {
            self.selectedRowIds = preselectedIds
        }
    }
    
    func updateAddButtonModel() {
        guard case .multipleItems = internalViewModel.selectionMode else { return }

        addButtonModel = selectedRowIds.isEmpty && !selectionMode.isPreselectModeAvailable ?
            .disabled :
            .enabled(counter: selectedRowIds.count)
    }
    
    func handleMultipleRowsSelection(rowId: String) {
        if selectedRowIds.contains(rowId) {
            selectedRowIds.removeAll { $0 == rowId }
        } else {
            selectedRowIds.append(rowId)
        }
        
        UISelectionFeedbackGenerator().selectionChanged()
        internalViewModel.handleRowsSelection(ids: selectedRowIds)
    }
    
}
