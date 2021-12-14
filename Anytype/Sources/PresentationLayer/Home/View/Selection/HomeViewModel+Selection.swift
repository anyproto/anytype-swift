import AnytypeCore
import BlocksModels
import UIKit

extension HomeViewModel {
    var isSelectionMode: Bool { binCellData.filter { $0.selected }.isNotEmpty }
    var isAllSelected: Bool { binCellData.first { !$0.selected }.isNil }
    var selectedPageIds: [BlockId] { binCellData.filter { $0.selected }.map { $0.id } }
    var numberOfSelectedPages: Int { binCellData.filter { $0.selected }.count }
    
    func selectAll(_ select: Bool) {
        binCellData.indices.forEach { index in
            binCellData[index].selected = select
        }
    }
    
    func select(data: HomeCellData) {
        guard let index = binCellData.firstIndex(where: { $0.id == data.id }) else {
            anytypeAssertionFailure("No page in bin for data: \(data)", domain: .homeView)
            return
        }
        
        binCellData[index].selected.toggle()
    }
    
    func restoreSelected() {
        objectActionsService.setArchive(objectIds: selectedPageIds, false)
        selectAll(false)
        updateBinTab()
    }
    
    func deleteSelected() {
        showDeletionAlert = true
    }
    
    func deleteConfirmation() {
        loadingAlertData = .init(text: "Deleting in progress", showAlert: true)
        
        objectActionsService.delete(objectIds: selectedPageIds) { [weak self] success in
            self?.loadingAlertData = .empty
            
            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self?.showDeletionAlert = false
                self?.selectAll(false)
                self?.updateBinTab()
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self?.snackBarData = .init(text: "Deletion error".localized, showSnackBar: true)
            }
        }
    }
}
