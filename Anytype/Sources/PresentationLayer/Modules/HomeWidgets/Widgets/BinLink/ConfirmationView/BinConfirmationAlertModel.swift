import Foundation
import Services
import SwiftUI

struct BinConfirmationAlertData: Identifiable, Hashable {
    let ids: [String]
    
    var id: Int { hashValue }
}

@MainActor
final class BinConfirmationAlertModel: ObservableObject {
    
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    
    private let ids: [String]
    
    var count: Int { ids.count }
    @Published var toastData: ToastBarData = .empty
    
    init(data: BinConfirmationAlertData) {
        self.ids = data.ids
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logShowDeletionWarning(route: .bin)
    }
    
    func onConfirm() async throws {
        AnytypeAnalytics.instance().logDeletion(count: ids.count, route: .bin)
        try await objectActionsService.delete(objectIds: ids)
        toastData = ToastBarData(text: Loc.Widgets.Actions.binConfirm(ids.count), showSnackBar: true)
    }
}
