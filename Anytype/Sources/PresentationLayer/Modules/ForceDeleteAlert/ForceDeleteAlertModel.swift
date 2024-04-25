import Foundation
import Services
import UIKit

struct ForceDeleteAlertData: Identifiable, Hashable {
    let objectIds: [String]
    
    var id: Int { hashValue }
}

@MainActor
final class ForceDeleteAlertModel: ObservableObject {
    
    @Injected(\.objectActionsService)
    private var objectActionService: ObjectActionsServiceProtocol
    
    private let objectIds: [String]
    
    init(data: ForceDeleteAlertData) {
        self.objectIds = data.objectIds
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logShowDeletionWarning(route: .settings)
    }
    
    func onDelete() async throws {
        AnytypeAnalytics.instance().logMoveToBin(true)
        try await objectActionService.setArchive(objectIds: objectIds, true)
        AnytypeAnalytics.instance().logDeletion(count: objectIds.count, route: .settings)
        try await objectActionService.delete(objectIds: objectIds)
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
