import Foundation
import Combine
import BlocksModels

@MainActor
final class BinLinkWidgetViewModel: ObservableObject, WidgetContainerContentViewModelProtocol {
    
    // MARK: - DI
    
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    let name = Loc.bin
    let icon: ImageAsset? = .Widget.bin
    let allowContent = false
    let menuItems: [WidgetMenuItem] = []
    
    init(output: CommonWidgetModuleOutput?) {
        self.output = output
    }
    
    // MARK: - WidgetContainerContentViewModelProtocol

    func onAppear() {
    }
    
    func onDisappear() {
    }
    
    func onHeaderTap() {
        // TODO: implement
    }
}
