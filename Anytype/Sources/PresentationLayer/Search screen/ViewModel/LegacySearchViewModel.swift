import Foundation
import SwiftUI
import Combine

@MainActor
final class LegacySearchViewModel: ObservableObject {
    
    let title: String?
    let searchPlaceholder: String
    let style: LegacySearchView.Style
    let focusedBar: Bool
    
    @Published private(set) var state: LegacySearchViewState = .resultsList(.plain(rows: []))
    @Published private(set) var addButtonModel: LegacySearchView.AddButtonModel? = nil
    @Published private(set) var createButtonModel: CreateButtonModel = .disabled
    
    private let itemCreationMode: ItemCreationMode
    private let selectionMode: SelectionMode
    private let internalViewModel: any NewInternalSearchViewModelProtocol
    
    private var cancellable: AnyCancellable? = nil
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
        cancellable = Task { @MainActor [weak self, internalViewModel] in
            for await state in internalViewModel.viewStatePublisher.values {
                self?.state = state
            }
        }.cancellable()
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
