import Foundation
import Services
import Combine

class CommonWidgetInternalViewModel {
    
    // MARK: - DI
    
    let widgetBlockId: BlockId
    let widgetObject: BaseDocumentProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    
    var widgetInfo: BlockWidgetInfo? {
        didSet {
            widgetInfoUpdated()
        }
    }
    var contentIsAppear = false
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startHeaderSubscription() {
        widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] widgetInfo in
                guard let self else { return }
                self.widgetInfo = widgetInfo
            }
            .store(in: &subscriptions)
    }
    
    func stopHeaderSubscription() {
        subscriptions.removeAll()
    }
    
    func startContentSubscription() {
        contentIsAppear = true
    }
    
    func stopContentSubscription() {
        contentIsAppear = false
    }
    
    func widgetInfoUpdated() {}
}
