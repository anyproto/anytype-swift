import Foundation
import SwiftUI
import Combine

final class NewSearchViewModel: ObservableObject {
    
    @Published private(set) var listModel: NewSearchView.ListModel = .plain(rows: [])
    @Published private(set) var addButtonModel: NewSearchView.AddButtonModel? = nil
    
    private let selectionMode: SelectionMode
    private let internalViewModel: NewInternalSearchViewModelProtocol
    private let onSelect: (_ ids: [String]) -> Void
    
    private var cancellable: AnyCancellable? = nil
    
    private var selectedRowIds: [String] = [] {
        didSet {
            updateAddButtonModel()
        }
    }
    
    init(
        selectionMode: SelectionMode,
        internalViewModel: NewInternalSearchViewModelProtocol,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) {
        self.selectionMode = selectionMode
        self.internalViewModel = internalViewModel
        self.onSelect = onSelect
        setup()
    }
}

extension NewSearchViewModel {
    
    func didAskToSearch(text: String) {
        internalViewModel.search(text: text)
    }
    
    func didSelectRow(with id: String) {
        switch selectionMode {
        case .singleItem:
            onSelect([id])
        case .multipleItems:
            handleMultipleRowsSelection(rowId: id)
        }
    }
    
    func didTapAddButton() {
        onSelect(selectedRowIds)
    }
    
}

private extension NewSearchViewModel {
    
    func setup() {
        setupInternalViewModel()
        updateAddButtonModel()
    }
    
    func setupInternalViewModel() {
        cancellable = internalViewModel.listModelPublisher.sink { [weak self] listModel in
            self?.listModel = listModel
        }
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
        
        internalViewModel.handleRowsSelection(ids: selectedRowIds)
    }
    
}
