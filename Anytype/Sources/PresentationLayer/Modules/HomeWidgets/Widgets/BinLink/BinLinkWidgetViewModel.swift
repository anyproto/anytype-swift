import Foundation
import Services
import UIKit

@MainActor
@Observable
final class BinLinkWidgetViewModel {

    // MARK: - DI

    @ObservationIgnored
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol

    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private weak var output: (any CommonWidgetModuleOutput)?

    // MARK: - State

    var toastData: ToastBarData?
    var binAlertData: BinConfirmationAlertData? = nil
    
    init(spaceId: String, output: (any CommonWidgetModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func onHeaderTap() {
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .bin, createType: .manual)
        output?.onObjectSelected(screenData: .editor(.bin(spaceId: spaceId)))
    }
    
    func onEmptyBinTap() async throws {
        let binIds = try await searchService.searchArchiveObjectIds(spaceId: spaceId)
        guard binIds.isNotEmpty else {
            toastData = ToastBarData(Loc.Widgets.Actions.binConfirm(binIds.count))
            return
        }
        binAlertData = BinConfirmationAlertData(ids: binIds)
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
