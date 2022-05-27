import Foundation
import SwiftUI
import Combine

final class NewSearchViewModel: ObservableObject {
    
    let title: String?
    
    @Published private(set) var listModel: NewSearchView.ListModel = .plain(rows: [])
    @Published private(set) var addButtonModel: NewSearchView.AddButtonModel? = nil
    @Published private(set) var isCreateButtonAvailable: Bool = false
    
    private let selectionMode: SelectionMode
    private let itemCreationMode: ItemCreationMode
    private let internalViewModel: NewInternalSearchViewModelProtocol
    private let onSelect: (_ ids: [String]) -> Void
    
    private var cancellable: AnyCancellable? = nil
    
    private var selectedRowIds: [String] = [] {
        didSet {
            updateAddButtonModel()
        }
    }
    
    init(
        title: String? = nil,
        selectionMode: SelectionMode,
        itemCreationMode: ItemCreationMode,
        internalViewModel: NewInternalSearchViewModelProtocol,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) {
        self.title = title
        self.selectionMode = selectionMode
        self.itemCreationMode = itemCreationMode
        self.internalViewModel = internalViewModel
        self.onSelect = onSelect
        setup()
    }
}

extension NewSearchViewModel {
    
    func didAskToSearch(text: String) {
        internalViewModel.search(text: text)
        updateCreateItemButtonState(searchText: text)
    }
    
    func didSelectRow(with id: String) {
        switch selectionMode {
        case .singleItem:
            onSelect([id])
        case .multipleItems:
            handleMultipleRowsSelection(rowId: id)
        }
    }
    
    func didTapCreateButton(title: String) {
        guard case .available(let action) = itemCreationMode else { return }
        action(title)
    }
    
    func didTapAddButton() {
        onSelect(selectedRowIds)
    }
    
}

private extension NewSearchViewModel {
    
    func setup() {
        setupInternalViewModel()
        updateCreateItemButtonState(searchText: "")
        updateAddButtonModel()
    }
    
    func setupInternalViewModel() {
        cancellable = internalViewModel.listModelPublisher.sink { [weak self] listModel in
            self?.listModel = listModel
        }
    }
    
    func updateCreateItemButtonState(searchText: String) {
        guard case .available = itemCreationMode else {
            isCreateButtonAvailable = false
            return
        }
        
        isCreateButtonAvailable = searchText.isNotEmpty
    }
    
    func updateAddButtonModel() {
        guard case .multipleItems = selectionMode else { return }

        addButtonModel = selectedRowIds.isEmpty ? .disabled : .enabled(counter: selectedRowIds.count)
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
