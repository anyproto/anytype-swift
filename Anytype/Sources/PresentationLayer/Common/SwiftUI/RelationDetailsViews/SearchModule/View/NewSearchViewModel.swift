import Foundation
import SwiftUI
import Combine

final class NewSearchViewModel: ObservableObject {
    
    @Published private(set) var listModel: NewSearchView.ListModel = .plain(rows: [])
    @Published private(set) var addButtonModel: NewSearchView.AddButtonModel? = nil
    
    private let selectionMode: SearchSelectionMode
    private let internalViewModel: NewInternalSearchViewModelProtocol
    private var cancellable: AnyCancellable? = nil
    
    private var selectedRowIds: [String] = [] {
        didSet {
            updateAddButtonModel()
        }
    }
    
    init(selectionMode: SearchSelectionMode, internalViewModel: NewInternalSearchViewModelProtocol) {
        self.selectionMode = selectionMode
        self.internalViewModel = internalViewModel
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
            internalViewModel.handleRowsSelection(ids: [id])
        case .multipleItems:
            handleMultipleItemsSelection(rowId: id)
        }
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
    
    func handleMultipleItemsSelection(rowId: String) {
        if selectedRowIds.contains(rowId) {
            selectedRowIds.removeAll { $0 == rowId }
        } else {
            selectedRowIds.append(rowId)
        }
        
        internalViewModel.handleRowsSelection(ids: selectedRowIds)
    }
    
}
