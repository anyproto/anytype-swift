import AnytypeCore
import BlocksModels
import UIKit
import Amplitude

extension HomeViewModel {
    var isSelectionMode: Bool { selectedPageIds.isNotEmpty }
    var isAllSelected: Bool { selectedPageIds.count == binCellData.count }
    var numberOfSelectedPages: Int { selectedPageIds.count }
    
    func selectAll(_ select: Bool) {
        if select {
            binCellData.forEach { selectedPageIds.update(with: $0.id) }
        } else {
            selectedPageIds = []
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
    }
    
    func deleteSelected() {
        showDeletionAlert = true

        Amplitude.instance().logEvent(AmplitudeEventsName.deletionWarningShow)
    }
    
    func deleteConfirmation() {
        loadingAlertData = .init(text: "Deleting in progress", showAlert: true)
        
        objectActionsService.delete(objectIds: Array(selectedPageIds)) { [weak self] success in
            self?.loadingAlertData = .empty
            
            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self?.showDeletionAlert = false
                self?.selectAll(false)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self?.snackBarData = .init(text: "Deletion error".localized, showSnackBar: true)
            }
        }
    }
}
