import Foundation
import Combine
import Services
import UIKit

@MainActor
final class BinWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var widgetActionsViewCommonMenuProvider: any WidgetActionsViewCommonMenuProviderProtocol
    
    let data: WidgetSubmoduleData
    
    var widgetBlockId: String { data.widgetBlockId }
    var widgetObject: any BaseDocumentProtocol { data.widgetObject }
    weak var output: (any CommonWidgetModuleOutput)? { data.output }
    
    // MARK: - State
    
    @Published var toastData: ToastBarData = .empty
    @Published var binAlertData: BinConfirmationAlertData? = nil
    var dragId: String { data.widgetBlockId }
    
    init(data: WidgetSubmoduleData) {
        self.data = data
    }
    
    func onHeaderTap() {
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .bin)
        data.output?.onObjectSelected(screenData: .editor(.bin(spaceId: data.workspaceInfo.accountSpaceId)))
    }
    
    func onEmptyBinTap() async throws {
        let binIds = try await searchService.searchArchiveObjectIds(spaceId: data.workspaceInfo.accountSpaceId)
        guard binIds.isNotEmpty else {
            toastData = ToastBarData(text: Loc.Widgets.Actions.binConfirm(binIds.count), showSnackBar: true)
            return
        }
        binAlertData = BinConfirmationAlertData(ids: binIds)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onDeleteWidgetTap() {
        widgetActionsViewCommonMenuProvider.onDeleteWidgetTap(
            widgetObject: data.widgetObject,
            widgetBlockId: data.widgetBlockId,
            homeState: data.homeState.wrappedValue
        )
    }
}
