import Foundation
import SwiftUI
import Combine

final class NewSearchViewModel: ObservableObject {
    
    let title: String?
    let searchPlaceholder: String
    let style: NewSearchView.Style
    
    @Published private(set) var state: NewSearchViewState = .resultsList(.plain(rows: []))
    @Published private(set) var addButtonModel: NewSearchView.AddButtonModel? = nil
    @Published private(set) var createButtonModel: NewSearchCreateButtonModel = NewSearchCreateButtonModel(show: false)
    
    private let itemCreationMode: ItemCreationMode
    private let selectionMode: SelectionMode
    private let internalViewModel: NewInternalSearchViewModelProtocol
    
    private var cancellable: AnyCancellable? = nil
    
    private var selectedRowIds: [String] = [] {
        didSet {
            updateAddButtonModel()
        }
    }
    
    init(
        title: String? = nil,
        searchPlaceholder: String = Loc.search,
        style: NewSearchView.Style = .default,
        itemCreationMode: ItemCreationMode,
        selectionMode: SelectionMode = .multipleItems(),
        internalViewModel: NewInternalSearchViewModelProtocol
    ) {
        self.title = title
        self.searchPlaceholder = searchPlaceholder
        self.style = style
        self.itemCreationMode = itemCreationMode
        self.selectionMode = selectionMode
        self.internalViewModel = internalViewModel
        setup()
    }
}

extension NewSearchViewModel {
    
    func didAskToSearch(text: String) {
        internalViewModel.search(text: text)
        updateCreateItemButtonState(searchText: text)
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

private extension NewSearchViewModel {
    
    func setup() {
        setupInternalViewModel()
        updateCreateItemButtonState(searchText: "")
        updateSelectedRowIds()
        updateAddButtonModel()
    }
    
    func setupInternalViewModel() {
        cancellable = internalViewModel.viewStateSubject.sink { [weak self] state in
            self?.state = state
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
