import Foundation
import Combine
import Services
import UIKit

@MainActor
final class BinLinkWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
    private let spaceId: String
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    @Published var toastData: ToastBarData = .empty
    @Published var binAlertData: BinConfirmationAlertData? = nil
    
    init(spaceId: String, output: CommonWidgetModuleOutput?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func onHeaderTap() {
        AnytypeAnalytics.instance().logSelectHomeTab(source: .bin)
        output?.onObjectSelected(screenData: .bin)
    }
    
    func onEmptyBinTap() async throws {
        let binIds = try await searchService.searchArchiveObjectIds(spaceId: spaceId)
        guard binIds.isNotEmpty else {
            toastData = ToastBarData(text: Loc.Widgets.Actions.binConfirm(binIds.count), showSnackBar: true)
            return
        }
        binAlertData = BinConfirmationAlertData(ids: binIds)
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
