import AnytypeCore
import BlocksModels
import UIKit

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
        showPagesDeletionAlert = true

        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.deletionWarningShow)
    }
    
    func pagesDeleteConfirmation() {
        loadingAlertData = .init(text: "Deleting in progress", showAlert: true)
        
        Task { @MainActor [weak self] in
            do {
                try await self?.objectActionsService.delete(objectIds: Array(selectedPageIds))
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self?.showPagesDeletionAlert = false
                self?.selectAll(false)
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self?.snackBarData = .init(text: Loc.deletionError, showSnackBar: true)
            }
            self?.loadingAlertData = .empty
        }
    }
}
