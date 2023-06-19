import Foundation
import Combine
import Services

@MainActor
final class BinLinkWidgetViewModel: ObservableObject, WidgetContainerContentViewModelProtocol {
    
    // MARK: - DI
    
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    let name = Loc.bin
    let icon: ImageAsset? = .Widget.bin
    let allowContent = false
    let menuItems: [WidgetMenuItem] = [.emptyBin]
    let dragId: String? = nil
    
    init(output: CommonWidgetModuleOutput?) {
        self.output = output
    }
    
    // MARK: - WidgetContainerContentViewModelProtocol

    func startHeaderSubscription() {}
    
    func stopHeaderSubscription() {}
    
    func startContentSubscription() {}
    
    func stopContentSubscription() {}
    
    func onHeaderTap() {
        AnytypeAnalytics.instance().logSelectHomeTab(source: .bin)
        output?.onObjectSelected(screenData: EditorScreenData(pageId: "", type: .bin))
    }
}
