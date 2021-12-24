import AnytypeCore
import BlocksModels
import UIKit

extension HomeViewModel {
    var isSelectionMode: Bool { selectedPageIds.isNotEmpty }
    var isAllSelected: Bool { selectedPageIds.count == binCellData.count }
    var numberOfSelectedPages: Int { selectedPageIds.count }
    
    func selectAll(_ select: Bool) {
        binCellData.forEach { data in
            if select {
                selectedPageIds.update(with: data.id)
            } else {
                selectedPageIds.remove(data.id)
            }
        }
    }
    
    func select(data: HomeCellData) {
        guard binCellData.contains(where: { $0.id == data.id }) else {
            anytypeAssertionFailure("No page in bin for data: \(data)", domain: .homeView)
            return
        }
        
        if selectedPageIds.contains(data.id) {
            selectedPageIds.remove(data.id)
        } else {
            selectedPageIds.update(with: data.id)
        }
    }
    
    func restoreSelected() {
        objectActionsService.setArchive(objectIds: Array(selectedPageIds), false)
        selectAll(false)
        updateBinTab()
    }
    
    func deleteSelected() {
        showDeletionAlert = true
    }
    
    func deleteConfirmation() {
        loadingAlertData = .init(text: "Deleting in progress", showAlert: true)
        
        objectActionsService.delete(objectIds: Array(selectedPageIds)) { [weak self] success in
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
